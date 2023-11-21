defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Aida.Stream.subscribe()

    {:ok, assign(socket, :response, "")}
  end

  @impl true
  def handle_info({:stream_response, content}, socket) do
    IO.inspect(content, label: "----------- STREAM RESPONSE INCOMING ---------")
    current_response = socket.assigns.response

    new_response = if content == nil, do: current_response, else: current_response <> content

    socket = assign(socket, :response, new_response)

    {:noreply, socket}
  end
end
