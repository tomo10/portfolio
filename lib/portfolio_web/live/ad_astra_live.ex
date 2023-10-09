defmodule PortfolioWeb.AdAstraLive do
  use PortfolioWeb, :live_view
  alias AdAstra.Api
  alias AdAstra.Stars.Star
  alias AdAstra.Trigonometry

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"star_name_1" => "", "star_name_2" => "", "speed" => ""}

    socket =
      assign(
        socket,
        result: nil,
        speed: "",
        star_1: %Star{},
        star_2: %Star{},
        form: to_form(form_params)
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def star(assigns) do
    ~H"""
    <div :if={@star.name != nil} class="p-8">
      <.h4><%= @star.name %></.h4>
      <p>Right ascension: <%= @star.right_ascension %></p>
      <p>Declination: <%= @star.declination %></p>
      <p>Light years from Earth: <%= @star.distance_light_year %></p>
    </div>
    """
  end

  @impl true
  def handle_event("save", params, socket) do
    case Api.fetch_stars(params["star_name_1"], params["star_name_2"]) do
      {:ok, stars} ->
        [star1, star2] = stars
        result = calculate_journey_time(star1, star2, params["speed"])
        speed = Trigonometry.map_speed(params["speed"])

        {:noreply, assign(socket, star_1: star1, star_2: star2, speed: speed, result: result)}

      {:error, msg} ->
        {:noreply, put_flash(socket, :error, msg)}
    end
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    # Go back to the :index live action
    {:noreply, push_patch(socket, to: "/ad-astra")}
  end

  def calculate_journey_time(star_1, star_2, speed) do
    Trigonometry.calculate_two_stars(star_1, star_2)
    |> Trigonometry.convert_speed(speed)
  end
end
