defmodule TrigonometryTest do
  use ExUnit.Case

  import AdAstra.Trigonometry,
    only: [
      right_asc_to_degrees: 1,
      declination_to_degrees: 1,
      rectangle_coordinates: 3,
      distance_between_stars: 3,
      calculate_two_stars: 2
    ]

  import AdAstra.DataParsing,
    only: [
      right_asc_to_number: 1,
      declination_to_number: 1
    ]

  test "Check the strings are formatted correctly to ints and floats" do
    assert right_asc_to_number("18h 36m 56.19s") == [18, 36, 56.19]
    assert declination_to_number("-16°  42′  58″") == [-16, 42, 58]
    assert declination_to_number("+38° 46′ 58.8″") == [38, 46, 58.8]
    assert declination_to_number("+38°46′58.8″") == [38, 46, 58.8]
    assert declination_to_number("+38°  46′  58.8″") == [38, 46, 58.8]
  end

  test "The right asc hours, mins, seconds are formatted to degrees" do
    assert right_asc_to_degrees([18, 36, 56.19]) == 279.234125
    assert right_asc_to_degrees([1, 5, 40]) == 16.416666666666664
  end

  test "The declination hours, mins, seconds are formatted to degrees" do
    assert declination_to_degrees([-16, 42, 58]) == -16.71611111111111
    assert declination_to_degrees([38, 47, 01]) == 38.78361111111111
  end

  test "Calculate the rectangle coordinates of 1 star" do
    assert rectangle_coordinates(200, 40, "25") == [
             -17.996157759823856,
             -6.5500657557346225,
             16.06969024216348
           ]

    assert rectangle_coordinates(100, 20, "25") == [
             -4.0793977791633695,
             23.135414459958085,
             8.550503583141717
           ]
  end

  test "Calc the distance between two stars" do
    assert distance_between_stars(4, 15, 10) == 18.47
    assert distance_between_stars(2, 8, 12) == 14.56
  end

  test "Calc distance between two stars given initial data" do
    sirius = %{
      declination: "-16°  42′  58″",
      distance_light_year: 8.6,
      name: "Sirius",
      right_ascension: "06h 45m 8.9s"
    }

    vega = %{
      declination: "+38°  47′  01″",
      distance_light_year: 25.3,
      name: "Vega",
      right_ascension: "18h 36m 56.19s"
    }

    assert calculate_two_stars(sirius, vega) == 33.42
  end
end
