defmodule TrigonometryTest do
  use ExUnit.Case

  import AdAstra.Trigonometry,
    only: [
      string_to_number: 1,
      right_asc_to_degrees: 1,
      rectangle_coordinates: 3,
      distance_between_stars_light_years: 3
    ]

  test "Check the strings are formatted correctly to ints and floats" do
    assert string_to_number("18h 36m 56.19s") == [18, 36, 56.19]
  end

  test "The right asc hours, mins, seconds are formatted to degrees" do
    assert right_asc_to_degrees([18, 36, 56.19]) == 279.234125
    assert right_asc_to_degrees([1, 5, 40]) == 16.416666666666664
  end

  test "Calc the light year distance between two stars" do
    assert distance_between_stars_light_years(4, 15, 10) == 18.47
    assert distance_between_stars_light_years(2, 8, 12) == 14.56
  end
end
