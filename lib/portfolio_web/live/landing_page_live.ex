defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"question" => ""}

    socket =
      assign(
        socket,
        page_title: "Ask Jeeves",
        form: to_form(form_params),
        response:
          "As an AI, I don't have personal preferences, but some popular films that people often enjoy are The Shawshank Redemption, The Godfather, and The Dark Knight."
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    response = Aida.Llm.test_aida(question)

    {:noreply, assign(socket, response: response.content)}
  end
end
