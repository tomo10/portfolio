defmodule PortfolioWeb.AidaLive do
  use PortfolioWeb, :live_component

  @impl true
  def mount(socket) do
    form_params = %{"question" => ""}

    socket =
      assign(
        socket,
        form: to_form(form_params)
        # response: nil
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="lg:flex-1 items-center justify-center text-center lg:text-left py-12 dark:from-gray-900 dark:to-gray-800">
      <div class="lg:h-128">
        <div class="flex items-center justify-center lg:h-128">
          <img
            id="hero-image"
            class="rounded-full lg:max-w-lg max-h-[100px]"
            src={~p"/images/landing_page/moi.jpeg"}
            alt=""
          />
        </div>

        <.form for={@form} phx-submit="submit" phx-target={@myself} class="my-10">
          <.field
            field={@form[:question]}
            placeholder="Ask me anything..."
            help_text="e.g. What are you working on at the moment ? What are your hobbies ? Are aliens real ?"
          />
          <.button color="primary" label="Ask me" size="lg" variant="inverted" />
        </.form>
        <%!-- <div class="flex justify-center">
          <.spinner show={@loading} size="lg" class="text-primary-500 mt-20" />
        </div> --%>
        <%!-- <div :if={@response} class="mt-10">
          <div class="p-5 text-white border-gray-200 rounded-lg bg-slate-800 text-semibold">
            <%= @response %>
          </div>
        </div> --%>
      </div>
    </section>
    """
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    # send(self(), {:ask_aida, question})

    Aida.Llm.ask_aida(question)

    {:noreply, socket}
  end

  # defp save_response(socket, response) do
  #   assign(socket, response: response)
  # end
end