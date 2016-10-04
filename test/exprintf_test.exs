defmodule ExPrintfTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import ExPrintf

  test "%d - integer" do
    assert(parse_printf("%d")    == "~w")
    assert(parse_printf("%5d")   == "~5w")
    assert(parse_printf("%-5d")  == "~-5w")
    assert(parse_printf("%010d") == "~10..0B")

    assert(sprintf("%d", [10])   == "10")
    assert(sprintf("%5d", [10])  == String.duplicate(" ", 3) <> "10")
    assert(sprintf("%-5d", [10]) == "10" <> String.duplicate(" ", 3))
    assert(sprintf("%05d", [10]) == String.duplicate("0", 3) <> "10")
    assert(sprintf("%0d", [10])  == "10")
  end

  test "%s - string" do
    assert(parse_printf("%s")    == "~ts")
    assert(parse_printf("%15s")  == "~15ts")
    assert(parse_printf("%010s") == "~10ts")

    assert(sprintf("%s", ["abc"])    == "abc")
    assert(sprintf("%15s", ["abc"])  == String.duplicate(" ", 12) <> "abc")
    assert(sprintf("%-15s", ["abc"]) == "abc" <> String.duplicate(" ", 12))
    assert(sprintf("%015s", ["abc"]) == String.duplicate(" ", 12) <> "abc")
    assert(sprintf("%0s", ["abc"])   == "abc")

    assert(sprintf("%s", ["測試"])    == "測試")
    assert(sprintf("%15s", ["測試"])  == String.duplicate(" ", 13) <> "測試")
    assert(sprintf("%-15s", ["測試"]) == "測試" <> String.duplicate(" ", 13))
    assert(sprintf("%015s", ["測試"]) == String.duplicate(" ", 13) <> "測試")
    assert(sprintf("%0s", ["測試"])   == "測試")
  end

  test "%f - float" do
    assert(parse_printf("%f")     == "~f")
    assert(parse_printf("%1f")    == "~1f")
    assert(parse_printf("%.3f")   == "~.3f")
    assert(parse_printf("%10.3f") == "~10.3f")
    assert(parse_printf("%010f")  == "~10..0f")

    assert(sprintf("%f", [10.0])    == "10.000000")
    assert(sprintf("%10f", [10.0])  == String.duplicate(" ", 1) <> "10.000000")
    assert(sprintf("%-10f", [10.0]) == "10.000000" <> String.duplicate(" ", 1))
    assert(sprintf("%.3f", [3.0])   == "3.000")
    assert(sprintf("%10.3f", [3.0]) == "     3.000")
    assert(sprintf("%010f", [10.0]) == String.duplicate("0", 1) <> "10.000000")
    assert(sprintf("%0f", [10.0])   == "10.000000")
  end

  test "%c - character" do
    assert(parse_printf("%c")    == "~c")
    assert(parse_printf("%10c")  == "~10.1c")
    assert(parse_printf("%010c") == "~10.1c")

    assert(sprintf("%c", [65])   == "A")
    assert(sprintf("%3c", [65])  == String.duplicate(" ", 2) <> "A")
    assert(sprintf("%-3c", [65]) == "A" <> String.duplicate(" ", 2))
    assert(sprintf("%03c", [65]) == String.duplicate(" ", 2) <> "A")
    assert(sprintf("%0c", [65])  == "A")
  end

  test "%i - alias for %d" do
    assert(parse_printf("%i")    == "~w")
    assert(parse_printf("%5i")   == "~5w")
    assert(parse_printf("%010i") == "~10..0B")

    assert(sprintf("%i", [10])   == "10")
    assert(sprintf("%5i", [10])  == String.duplicate(" ", 3) <> "10")
    assert(sprintf("%-5i", [10]) == "10" <> String.duplicate(" ", 3))
    assert(sprintf("%05i", [10]) == String.duplicate("0", 3) <> "10")
    assert(sprintf("%0i", [10])  == "10")
  end

  test "%b - unsigned integer in binary" do
    assert(parse_printf("%b")     == "~.2b")

    assert(sprintf("%b", [10])    == "1010")
    assert(sprintf("%10b", [10])  == String.duplicate(" ", 6) <> "1010")
    assert(sprintf("%-10b", [10]) == "1010" <> String.duplicate(" ", 6))
    assert(sprintf("%010b", [10]) == String.duplicate("0", 6) <> "1010")
    assert(sprintf("%0b", [10])   == "1010")
  end

  test "%o - unsigned integer in octal" do
    assert(parse_printf("%o")      == "~.8b")

    assert(sprintf("%o", [100])    == "144")
    assert(sprintf("%10o", [100])  == String.duplicate(" ", 7) <> "144")
    assert(sprintf("%-10o", [100]) == "144" <> String.duplicate(" ", 7))
    assert(sprintf("%010o", [100]) == String.duplicate("0", 7) <> "144")
    assert(sprintf("%0o", [100])   == "144")
  end

  test "%x - unsigned integer in hexadecimal" do
    assert(parse_printf("%x")       == "~.16b")
    assert(parse_printf("%10x")     == "~10.16b")
    assert(parse_printf("%010x")    == "~10.16.0b")

    assert(sprintf("%x", [1000])    == "3e8")
    assert(sprintf("%10x", [1000])  == String.duplicate(" ", 7) <> "3e8")
    assert(sprintf("%-10x", [1000]) == "3e8" <> String.duplicate(" ", 7))
    assert(sprintf("%010x", [1000]) == String.duplicate("0", 7) <> "3e8")
    assert(sprintf("%0x", [1000])   == "3e8")
  end

  test "%X - unsigned integer in hexadecimal with capitalized" do
    assert(parse_printf("%X")       == "~.16B")
    assert(parse_printf("%10X")     == "~10.16B")
    assert(parse_printf("%010X")    == "~10.16.0B")

    assert(sprintf("%X", [1000])    == "3E8")
    assert(sprintf("%10X", [1000])  == String.duplicate(" ", 7) <> "3E8")
    assert(sprintf("%-10X", [1000]) == "3E8" <> String.duplicate(" ", 7))
    assert(sprintf("%010X", [1000]) == String.duplicate("0", 7) <> "3E8")
    assert(sprintf("%0X", [1000])   == "3E8")
  end

  test "%e - float in 1.00000e+01 format" do
    assert(parse_printf("%e")      == "~e")
    assert(parse_printf("%.3e")    == "~.4e")

    assert(sprintf("%e", [10.0])   == "1.00000e+1")
    assert(sprintf("%e", [0.1])    == "1.00000e-1")
    assert(sprintf("%.3e", [10.0]) == "1.000e+1")
  end

  test "escape control characters of elixir" do
    assert(parse_printf("~") == "~~")
    assert(sprintf("~", []) == "~")
  end

  test "escape control characters of sprintf" do
    assert(parse_printf("%%") == "%")
    assert(sprintf("%%", []) == "%")
  end

  test "multiple format strings" do
    assert(parse_printf("%d %d") == "~w ~w")
    assert(parse_printf("%d %s") == "~w ~ts")

    assert(sprintf("%d %d", [10, 10])    == "10 10")
    assert(sprintf("%d %s", [10, "abc"]) == "10 abc")
    assert(sprintf("%d %s", [10, "測試"]) == "10 測試")
  end

  test "no format strings" do
    assert(parse_printf("a") == "a")
    assert(sprintf("a") == "a")
  end

  test "smaller length prints asterisk" do
    assert(sprintf("%1f", [10.0]) == "*")
    assert(sprintf("%2f", [10.0]) == "**")
  end

  test "parse invalid format charactor fails" do
    assert_raise ArgumentError, fn ->
      parse_printf("%&")
    end
  end

  test "passing integer on %f doesn't work" do
    assert_raise ArgumentError, fn ->
      sprintf("%f", [10])
    end
  end

  test "passing non-list in the 2nd argument throws error" do
    assert_raise RuntimeError, fn ->
      sprintf("%d", 10)
    end
  end

  test "parse non-ending % fails" do
    assert_raise ArgumentError, "malformed format string - not ending %", fn ->
      sprintf("%")
    end

    assert_raise ArgumentError, "malformed format string - not ending %", fn ->
      sprintf("%d%", [10])
    end
  end

  test "printf" do
    assert capture_io(fn ->
      printf("%d %s", [10, "abc"])
    end) == "10 abc"

    assert capture_io(fn ->
      printf("%f\n", [10.0])
    end) == "10.000000\n"

    assert capture_io(fn ->
      printf("a")
    end) == "a"

    assert_raise RuntimeError, fn ->
      printf("%d", 10)
    end
  end
end
