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
    # this function is only being called AFTER the stream of responses has finished. Undesirable behaviour atm.
    current_response = socket.assigns.response

    # deals with the first and last message deltas being nil
    updated_response = if content == nil, do: current_response, else: current_response <> content

    {:noreply, assign(socket, :response, updated_response)}
  end
end
