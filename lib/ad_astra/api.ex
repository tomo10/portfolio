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
      {:error, "Houston we have a problem"}
    end
  end

  def fetch_star(star, atom) do
    case fetch(star) do
      {:ok, body} ->
        values = extract_values_from_star(body)
        Stars.put(atom, values)

      {:error, msg} ->
        IO.puts("Network error with the api #{msg}")
    end
  end

  def fetch(star) do
    ninja_url(star)
    |> HTTPoison.get(@api_key)
    |> handle_response()
  end

  def extract_values_from_star(api_result) do
    case api_result do
      [head | _tail] ->
        %{
          name: Map.get(head, "name"),
          declination: Map.get(head, "declination"),
          right_ascension: Map.get(head, "right_ascension"),
          distance_light_year: Map.get(head, "distance_light_year")
        }

      [] ->
        nil
    end
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
end
