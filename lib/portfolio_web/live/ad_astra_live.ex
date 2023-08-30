defmodule PortfolioWeb.AdAstraLive do
  use PortfolioWeb, :live_view
  alias AdAstra.Api
  alias AdAstra.Stars
  alias AdAstra.Stars.Star
  alias AdAstra.Trigonometry

  @impl true
  def mount(_params, _session, socket) do
    cs = Stars.change_star(%Star{})

    socket =
      assign(
        socket,
        result: nil,
        star1: %Star{},
        star2: %Star{},
        form: to_form(cs)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"star" => star_params}, socket) do
    case Api.fetch_stars(star_params["star1"], star_params["star2"]) do
      {:ok, stars} ->
        [star1, star2] = stars
        {:noreply, assign(socket, star1: star1, star2: star2)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Houston we have a problem")}
    end
  end

  def handle_event("calculate", _, socket) do
    distance =
      Trigonometry.calculate_two_stars(
        socket.assigns.star1,
        socket.assigns.star2,
        socket.assigns.star1.distance_light_year,
        socket.assigns.star2.distance_light_year
      )

    {:noreply, assign(socket, :result, distance)}
  end

  def handle_event("type", params, socket) do
    {:noreply, socket}
  end
end
