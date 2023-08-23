defmodule PortfolioWeb.AdAstraLive do
  use PortfolioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, star_name: "", form: to_form(%{}))
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"star_name" => star_name}, socket) do
    socket = assign(socket, star_name: star_name)

    {:noreply, assign(socket, :form, to_form(%{}))}
  end
end
