defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, response: "", parent_pid: self())}
  end

  @impl true
  def handle_info({:delta_response, content}, socket) do
    # move the live compoent logic render back into landing page directly and remove the live component
    current_response = socket.assigns.response

    # deals with the first and last message deltas being nil
    updated_response = if content == nil, do: current_response, else: current_response <> content

    {:noreply, assign(socket, :response, updated_response)}
  end
end
