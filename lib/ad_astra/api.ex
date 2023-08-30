defmodule AdAstra.Api do
  use HTTPoison.Base
  alias AdAstra.Stars

  @api_key [{"X-Api-Key", "IZUmKgtnaQNAGgJdGrdQ3w==fYQue8KWKENTnuh9"}]

  def fetch_stars(star_1, star_2) do
    Stars.start_link([])

    fetch_star(star_1, :star_1)
    fetch_star(star_2, :star_2)

    if length(Stars.stars()) == 2 do
      {:ok, Stars.stars()}
    else
      {:error, "We don't have two stars"}
    end
  end

  def fetch_star(star, atom) do
    case fetch(star) do
      {:ok, body} ->
        Stars.put(atom, extract_values_from_star(body))

      {:error, _} ->
        IO.puts("We have a problem with star 1")
    end
  end

  def fetch(star) do
    ninja_url(star)
    |> HTTPoison.get(@api_key)
    |> handle_response()
  end

  def extract_values_from_star(api_result) do
    %{
      name: extract_value_from_star("name", api_result),
      declination: extract_value_from_star("declination", api_result),
      right_ascension: extract_value_from_star("right_ascension", api_result),
      distance_light_year: extract_value_from_star("distance_light_year", api_result)
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

  def extract_value_from_star(key, star) do
    Enum.map(star, fn %{^key => value} -> value end) |> hd()
  end
end
