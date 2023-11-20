defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  # alias Phoenix.LiveView.JS
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"question" => ""}

    socket =
      assign(
        socket,
        form: to_form(form_params),
        response: nil,
        loading: false
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    send(self(), {:ask_aida, question})

    {:noreply, assign(socket, loading: true, response: nil)}
  end

  @impl true
  def handle_info({:ask_aida, question}, socket) do
    response = Aida.Llm.ask_aida(question)

    {:noreply, assign(socket, response: response.content, loading: false)}
  end
end
