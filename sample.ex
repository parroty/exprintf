defmodule Sample do
  import ExPrintf

  def test do
    printf("number = %d\n", [10])  # -> number = 10
    IO.puts sprintf("string = %s", ["abc"])  # -> string = abc

    format = parse_printf("format = %d %.2f\n")
    IO.inspect format  # -> "format = ~w ~.2f\n"
    :io.format(format, [10, 10.153])  # -> format = 10 10.15
  end
end

Sample.test

