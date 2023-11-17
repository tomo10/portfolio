defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias Phoenix.LiveView.JS
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"question" => ""}

    socket =
      assign(
        socket,
        page_title: "Ask Jeeves",
        form: to_form(form_params),
        response: ""
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    # response = Aida.Llm.test_aida(question)
    response = "I'm sorry, my responses are limited. You must ask the right questions."
    JS.show()
    {:noreply, assign(socket, response: response)}
  end
end
