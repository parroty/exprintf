defmodule ExPrintf do
  @moduledoc """
  A printf/sprintf library for Elixir. It works as a wrapper for :io.format.
  """

  defrecord State,
    percent: false,   # becomes true after % is parsed
    width: 0,         # size of width (ex. %5d)
    precision: 0,     # size of precision (ex. %.5f)
    padding: false,   # becomes true if prefixed with zero (ex. %05d)
    negative: false,  # becomes true if negative value is specified (ex. %-5d)
    period: false     # becomes true after . is parsed

  # index number for record fields
  @record_index_percent 1
  @record_index_width   2
  @record_index_period  6

  @doc """
  Prints the parsed string to stdout based the printf-formatted input parameters.
  The params argument needs to be List.

  ## Examples

      iex> printf("%d\\n", [10])
      10
      :ok

  """
  def printf(format, params \\ []) when is_list(params) do
    IO.write sprintf(format, params)
  end

  def printf(_format, _params) do
    raise_param_error("printf")
  end

  @doc """
  Returns the parsed string based on the printf-formatted input parameters.
  The params argument needs to be List.

  ## Examples

      iex> sprintf("%d\\n", [10])
      "10\\n"

  """
  def sprintf(format, params \\ []) when is_list(params) do
    char_list = :io_lib.format(parse_printf(format), params)
    String.from_char_list!(char_list)
  end

  def sprintf(_format, _params) do
    raise_param_error("sprintf")
  end

  defp raise_param_error(function_name) do
    raise "The 2nd argument needs to be List: ex. #{function_name}(\"%d\", [10])"
  end

  @doc """
  Returns the Elixir's :io.format string based on the printf-formatted input parameters.
  The params argument needs to be List.

  ## Examples

      iex> parse_printf("%05d\\n")
      "~5..0B\\n"

  """
  def parse_printf(format) do
    parse_format(format, [], State.new)
  end

  defp parse_format(<<>>, _acc, state) when elem(state, @record_index_percent) == true do
    raise ArgumentError.new(message: "malformed format string - not ending %")
  end

  defp parse_format(<<>>, acc, _state) do
    Enum.join(Enum.reverse(acc), "")
  end

  defp parse_format(<< head :: utf8, tail :: binary >>, acc, state) when elem(state, @record_index_percent) == false do
    case head do
      ?%   -> parse_format(tail, acc, state.update(percent: true))
      ?~   -> parse_format(tail, ["~~" | acc], state)
      char -> parse_format(tail, [<<char>> | acc], state)
    end
  end

  defp parse_format(<< head :: utf8, tail :: binary >>, acc, state) when elem(state, @record_index_percent) == true do
    case head do
      # prefixed zero
      ?0 when elem(state, @record_index_width) == 0 ->
        parse_format(tail, acc, state.update(padding: true))

      # numbers before period
      head when head in ?0..?9 and elem(state, @record_index_period) == false ->
        parse_format(tail, acc, state.update(width: (state.width * 10 + (head - ?0))))

      # numbers after period
      head when head in ?0..?9 and elem(state, @record_index_period) == true ->
        parse_format(tail, acc, state.update(precision: (state.precision * 10 + (head - ?0))))

      ?- -> parse_format(tail, acc, state.update(negative: true))
      ?. -> parse_format(tail, acc, state.update(period: true))
      ?% -> parse_format(tail, ["%" | acc], reset(state))

      ?d -> parse_character("w", tail, acc, state)
      ?i -> parse_character("w", tail, acc, state)
      ?s -> parse_character("s", tail, acc, state)
      ?f -> parse_character("f", tail, acc, state)
      ?g -> parse_character("g", tail, acc, state)
      ?c -> parse_character("c", tail, acc, state)
      ?e -> parse_character("e", tail, acc, state)

      ?b -> parse_character("b",  2, tail, acc, state)
      ?o -> parse_character("b",  8, tail, acc, state)
      ?x -> parse_character("b", 16, tail, acc, state)
      ?X -> parse_character("B", 16, tail, acc, state)

      _  -> raise ArgumentError.new(message: "malformed format string - %#{<<head>>}")
    end
  end

  defp parse_character(type, tail, acc, state) do
    parse_format(tail, [handle_options(state, type) | acc], reset(state))
  end

  defp parse_character(type, base, tail, acc, state) do
    parse_format(tail, [handle_options(state, type, base) | acc], reset(state))
  end

  defp reset(_state) do
    State.new
  end

  defp handle_options(state, char, option \\ nil) do
    cond do
      # conversion for zero-padding
      char == "w" and has_padding(state)   -> "~#{do_handle_options(state)}..0B"
      char == "g" and has_padding(state)   -> "~#{do_handle_options(state)}..0g"
      char == "f" and has_padding(state)   -> "~#{do_handle_options(state)}..0f"
      char == "b" and has_padding(state)   -> "~#{do_handle_options(state)}.#{option}.0b"
      char == "B" and has_padding(state)   -> "~#{do_handle_options(state)}.#{option}.0B"

      # handling for characters
      char == "c" and has_width(state)     ->  "~#{do_handle_options(state)}.1c"

      # handling for float numbers
      char == "f" and has_precision(state) -> "~#{do_handle_options(state)}f"
      char == "e" and has_precision(state) -> "~#{do_handle_options(state, [precision: 1])}e"

      # handling for base-* numbers
      char == "b"                          -> "~#{do_handle_options(state)}.#{option}b"
      char == "B"                          -> "~#{do_handle_options(state)}.#{option}B"

      has_width(state)                     -> "~#{do_handle_options(state)}#{char}"
      true                                 -> "~#{char}"
    end
  end

  defp has_padding(state),   do: state.padding and has_width(state)
  defp has_width(state),     do: state.width > 0
  defp has_precision(state), do: state.precision > 0

  defp do_handle_options(state, offset \\ [precision: 0]) do
    sign      = get_sign_chars(state.negative)
    width     = get_width_chars(state.width)
    precision = get_precision_chars(state.precision + offset[:precision])

    "#{sign}#{width}#{precision}"
  end

  defp get_sign_chars(true),  do: "-"
  defp get_sign_chars(false), do: ""

  defp get_width_chars(x) when x > 0, do: x
  defp get_width_chars(_x),           do: ""

  defp get_precision_chars(x) when x > 0, do: ".#{x}"
  defp get_precision_chars(_x),           do: ""
end
