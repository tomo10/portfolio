defmodule AdAstraApiTest do
  use ExUnit.Case

  import AdAstra.Api, only: [extract_value_from_star: 2]

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

    assert extract_value_from_star("right_ascension", {:ok, star_list}) == "18h 36m 56.19s"
    assert extract_value_from_star("declination", {:ok, star_list}) == "+38° 46′ 58.8″"
  end
end
