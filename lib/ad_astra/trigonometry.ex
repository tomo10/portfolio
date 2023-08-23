defmodule AdAstra.Trigonometry do
  def string_to_int(right_asc_string) do
    String.split(right_asc_string)
    |> Enum.map(&trim/1)
    |> Enum.map(&to_number/1)
  end

  def to_number(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      String.to_integer(str)
    end
  end

  def trim(str), do: String.replace(str, ~r/[^0-9.]/, "")

  def right_asc_to_degrees(right_asc_arr) do
    [h, m, s] = right_asc_arr
    decimal_value = h + m / 60 + s / 3600
    decimal_value * 15
  end

  def rectangle_coordinates(right_asc, decl, r) do
    right_asc = to_radians(right_asc)
    decl = to_radians(decl)

    x = r * :math.cos(right_asc) * :math.cos(decl)
    y = r * :math.sin(right_asc) * :math.cos(decl)
    z = r * :math.sin(decl)

    [x, y, z]
  end

  def to_radians(deg), do: deg * :math.pi() / 180

  def rectangluar_coordinates_delta(x1, x2, y1, y2, z1, z2) do
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1
    [dx, dy, dz]
  end

  def distance_between_stars_light_years(dx, dy, dz) do
    d = dx * dx + dy * dy + dz * dz
    Float.round(:math.sqrt(d), 2)
  end
end
