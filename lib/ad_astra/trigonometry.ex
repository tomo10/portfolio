defmodule AdAstra.Trigonometry do
  import Number

  def right_asc_to_number(right_asc) do
    String.split(right_asc, ~r/[^0-9.-]+/)
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(&to_number/1)
  end

  @spec declination_to_number(binary) :: list
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

  defp to_number(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      String.to_integer(str)
    end
  end

  def right_asc_to_degrees(right_asc_arr) do
    [h, m, s] = right_asc_arr
    decimal_value = h + m / 60 + s / 3600
    decimal_value * 15
  end

  def declination_to_degrees([d, m, s]) when d < 0 do
    d - m / 60 - s / 3600
  end

  def declination_to_degrees([d, m, s]) when d >= 0 do
    d + m / 60 + s / 3600
  end

  def rectangle_coordinates(right_asc, decl, r) do
    right_asc = to_radians(right_asc)
    decl = to_radians(decl)
    r = to_number(r)

    x = r * :math.cos(right_asc) * :math.cos(decl)
    y = r * :math.sin(right_asc) * :math.cos(decl)
    z = r * :math.sin(decl)

    [x, y, z]
  end

  def to_radians(deg), do: deg * :math.pi() / 180

  def rectangluar_coordinates_delta(x1, y1, z1, x2, y2, z2) do
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1
    [dx, dy, dz]
  end

  @doc """
  This takes in 2 star names, their distance from earth in light years, and returns distance in light years
  """
  def calculate_two_stars(star1, star2, r1, r2) do
    decl1 = declination_total_parse(star1.declination)
    decl2 = declination_total_parse(star2.declination)
    right_asc1 = right_asc_total_parse(star1.right_ascension)
    right_asc2 = right_asc_total_parse(star2.right_ascension)

    [x1, y1, z1] = rectangle_coordinates(right_asc1, decl1, r1)
    [x2, y2, z2] = rectangle_coordinates(right_asc2, decl2, r2)

    [dx, dy, dz] = rectangluar_coordinates_delta(x1, y1, z1, x2, y2, z2)

    distance_between_stars(dx, dy, dz)
  end

  @doc """
  This takes in distance between 2 stars in light years, the new speed, and returns travel time in years
  "1" -> Speed of light
  "2" -> Voyager 1
  "3" -> Space Shuttle
  "4" -> Jumbo Jet
  """
  def convert_speed(light_years, speed) do
    case speed do
      "1" ->
        light_years

      "2" ->
        light_years * 17560

      "3" ->
        light_years * 38343

      "4" ->
        light_years * 1_092_833
    end
    |> Number.Delimit.number_to_delimited(precision: 0)

    # |> :erlang.float_to_binary(decimals: 0)
  end

  defp right_asc_total_parse(right_asc) do
    right_asc
    |> right_asc_to_number()
    |> right_asc_to_degrees()
  end

  defp declination_total_parse(declination) do
    [d, m, s] =
      declination_to_number(declination)

    declination_to_degrees([d, m, s])
  end

  def distance_between_stars(dx, dy, dz) do
    d = dx * dx + dy * dy + dz * dz
    Float.round(:math.sqrt(d), 2)
  end
end
