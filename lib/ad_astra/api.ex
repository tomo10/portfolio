defmodule AdAstra.Api do
  use HTTPoison.Base

  @api_key [{"X-Api-Key", "IZUmKgtnaQNAGgJdGrdQ3w==fYQue8KWKENTnuh9"}]

  def fetch(star) do
    res =
      ninja_url(star)
      |> HTTPoison.get(@api_key)
      |> handle_response()

    %{
      name: extract_value_from_star("name", res),
      declination: extract_value_from_star("declination", res),
      right_ascension: extract_value_from_star("right_ascension", res),
      distance_light_year: extract_value_from_star("distance_light_year", res)
    }
  end

  def ninja_url(star) do
    "https://api.api-ninjas.com/v1/stars?name=#{star}"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      check_for_error(status_code),
      Poison.Parser.parse!(body)
    }
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error

  def extract_value_from_star(key, {:ok, star}) do
    Enum.map(star, fn %{^key => value} -> value end) |> hd()
  end

  def stars_to_light_year, do: true
end
