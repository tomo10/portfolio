defmodule AdAstraApiTest do
  use ExUnit.Case

  import AdAstra.Api, only: [extract_values_from_star: 1]

  test "get the declination value from the star json list" do
    star_list = [
      %{
        "absolute_magnitude" => "0.58",
        "apparent_magnitude" => "0.03",
        "constellation" => "Lyra",
        "declination" => "+38° 46′ 58.8″",
        "distance_light_year" => "25",
        "name" => "Vega",
        "right_ascension" => "18h 36m 56.19s",
        "spectral_class" => "A0Vvar"
      }
    ]

    value = %{
      name: "Vega",
      declination: "+38° 46′ 58.8″",
      right_ascension: "18h 36m 56.19s",
      distance_light_year: "25"
    }

    assert extract_values_from_star(star_list) == value
    assert extract_values_from_star([]) == nil
  end
end
