defmodule PortfolioWeb.AdAstraLive do
  use PortfolioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  def handle_event(event, unsigned_params, socket) do
    {:noreply, socket}
  end
end
