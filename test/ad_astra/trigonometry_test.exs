defmodule TrigonometryTest do
  use ExUnit.Case

  import AdAstra.Trigonometry,
    only: [
      string_to_number: 1,
      right_asc_to_degrees: 1,
      declination_to_degrees: 1,
      rectangle_coordinates: 3,
      distance_between_stars: 3,
      calculate_two_stars: 4
    ]

  test "Check the strings are formatted correctly to ints and floats" do
    assert string_to_number("18h 36m 56.19s") == [18, 36, 56.19]
    assert string_to_number("-16°  42′  58″") == [-16, 42, 58]
  end

  test "The right asc hours, mins, seconds are formatted to degrees" do
    assert right_asc_to_degrees([18, 36, 56.19]) == 279.234125
    assert right_asc_to_degrees([1, 5, 40]) == 16.416666666666664
  end

  test "The declination hours, mins, seconds are formatted to degrees" do
    assert declination_to_degrees([-16, 42, 58]) == -16.71611111111111
    assert declination_to_degrees([38, 47, 01]) == 38.78361111111111
  end

  test "Calc the distance between two stars" do
    assert distance_between_stars(4, 15, 10) == 18.47
    assert distance_between_stars(2, 8, 12) == 14.56
  end

  test "Calc distance between two start given initial data" do
    sirius = %{
      declination: "-16°  42′  58″",
      distance_light_year: 25,
      name: "Sirius",
      right_ascension: "06h 45m 8.9s"
    }

    vega = %{
      declination: "+38°  47′  01″",
      distance_light_year: 25,
      name: "Vega",
      right_ascension: "18h 36m 56.19s"
    }

    assert calculate_two_stars(sirius, vega, 8.6, 25.3) == 33.42
  end
end
