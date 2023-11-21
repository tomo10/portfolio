defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Aida.Llm.subscribe()

    form_params = %{"question" => ""}

    socket =
      assign(
        socket,
        form: to_form(form_params),
        response: nil
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    # send(self(), {:ask_aida, question})
    Aida.Llm.subscribe()

    Aida.Llm.ask_aida(question)

    {:noreply, assign(socket, response: nil)}
  end

  @impl true
  def handle_info({:stream_response, content}, socket) do
    # IO.puts("")
    IO.inspect(content, label: "STREAM RESPONSE CONTENT")
    socket = stream_insert(socket, :response, content)

    {:noreply, socket}
  end
end
