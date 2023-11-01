defmodule AdAstra.DataParsing do
  def right_asc_to_number(right_asc) do
    String.split(right_asc, ~r/[^0-9.-]+/)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(&to_number/1)
  end

  def declination_to_number(decl) do
    String.split(decl, ~r/[^0-9.-]+/)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> check_array()
    |> Enum.map(&to_number/1)
  end

  def check_array(arr) when length(arr) > 1, do: arr

  def check_array(arr) when length(arr) == 1 do
    string = hd(arr)
    d = String.split_at(string, 2) |> elem(0)
    m = String.split_at(string, 4) |> elem(0)
    s = String.split_at(string, 6) |> elem(1)
    [d, m, s]
  end

  @doc """
  Formats a string to a number or a float
  """
  def to_number(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      String.to_integer(str)
    end
  end
end
