defmodule PortfolioWeb.AdAstraLive do
  use PortfolioWeb, :live_view
  alias AdAstra.Api
  alias AdAstra.Stars.Star
  alias AdAstra.Trigonometry
  alias Phoenix.LiveView.AsyncResult

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"star_name" => "", "speed" => ""}

    socket =
      assign(
        socket,
        result: nil,
        async_result: %AsyncResult{},
        speed: "",
        star: %Star{},
        stars: [],
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
    <div
      phx-click="remove-star"
      phx-value-star-id={@star.name}
      style="cursor: pointer"
      class="p-8 mr-4 border-4 border-gray-300 border-dashed rounded-lg dark:border-gray-800"
    >
      <.h4><%= @star.name %></.h4>
      <p>Right ascension: <%= @star.right_ascension %></p>
      <p>Declination: <%= @star.declination %></p>
      <p>Light years from Earth: <%= @star.distance_light_year %></p>
    </div>
    """
  end

  @impl true
  def handle_event("save-star", params, socket) do
    socket =
      start_star_task(socket, params)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-star", %{"star-id" => star_id}, socket) do
    stars = Enum.reject(socket.assigns.stars, fn star -> star.name == star_id end)

    socket = assign(socket, :stars, stars)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    # Go back to the :index live action
    {:noreply, push_patch(socket, to: "/ad-astra")}
  end

  @impl true
  def handle_event("calculate", %{"speed" => speed}, socket) do
    [star1, star2] = socket.assigns.stars

    result = calculate_journey_time(star1, star2, speed)
    speed = Trigonometry.map_speed(speed)

    {:noreply, assign(socket, speed: speed, result: result)}
  end

  def start_star_task(socket, params) do
    socket
    |> assign(:async_result, AsyncResult.loading())
    |> start_async(:async_task, fn ->
      Api.fetch_star(params["star_name"])
    end)
  end

  def handle_async(:async_task, {:ok, {:ok, [], failed_star}}, socket) do
    socket =
      assign(
        socket,
        :async_result,
        AsyncResult.failed(%AsyncResult{}, "#{failed_star} not found")
      )

    {:noreply, socket}
  end

  def handle_async(:async_task, {:ok, {:ok, fetched_star}}, socket) do
    stars =
      if length(socket.assigns.stars) == 2,
        do: socket.assigns.stars,
        else: [fetched_star | socket.assigns.stars]

    socket = assign(socket, :async_result, AsyncResult.ok(%AsyncResult{}, :ok))

    {:noreply, assign(socket, :stars, stars)}
  end

  def calculate_journey_time(star_1, star_2, speed) do
    Trigonometry.calculate_two_stars(star_1, star_2)
    |> Trigonometry.convert_speed(speed)
  end
end
