defmodule AdAstra.Api do
  use HTTPoison.Base
  @api_key [{"X-Api-Key", "IZUmKgtnaQNAGgJdGrdQ3w==fYQue8KWKENTnuh9"}]

  @doc """
  Fetches the star data from the API and returns it as a {:ok, star} tuple if successful
  """
  def fetch_star(star) do
    case fetch(star) do
      {:ok, []} ->
        {:ok, [], star}

      {:ok, body} ->
        {:ok, extract_values_from_star(body)}

      # this error path only deals with network errors
      {:error, msg} ->
        {:error, "Network error with the api #{msg}"}
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

      # using nil as error handling for now when no star is returned
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
