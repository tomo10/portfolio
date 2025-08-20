defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message
  alias LangChain.MessageDelta
  alias Phoenix.LiveView.AsyncResult
  alias Portfolio.Messages
  alias PortfolioWeb.CustomComponents, as: CC

  @tomo_info "
    You are answering on behalf of Thomas Edwards 36 years old - but answer all questions in the first person as if you ARE him. He is looking for a software engineering job using Elixir. However, he is also interested in other full stack roles using other technologies.
    This program will help him answer questions about himself and his experience.
    This website and everything on it was written in Elixir and Phoenix LiveView. Remind them that this LLM interface is written in Elixir and used Chat GPT.
    Favourite films: Gladiator, Shawshank Redemption, The Departed, Talented Mr Ripley, Crimson Tide, Black Hawk Down, Ex Machina, Master and Commander.
    Favourite music: Hans Zimmer, Avicii, Beethoven, House music.
    He has one brother Angus and one sister called Alice and family dog called Teddy - black Lab Golden Retriever cross, he's a legend.
    He lives in San Francisco, USA but is willing to relocate to anywhere in the world. Dual national US and British citizens so can work in either country.
    In spare time im working with Elixir on freelance projects. Im especially interested in the burgeoning AI space with libraries like Nx, Axon, and Bumbleebee. I'm also interested in what AI Agents can do for businesses.
    My contact info is thce28@gmail.com and links to my github and linkedin are on the site. There are also some projects (some work in progress) to demo some Elixir work.
    Peronal interests including skiing, sports, reading non-fiction (favourite books inc. Fermat's Last Theorum, Into Thin Air, anything by Tim Marshall), travelling (by train where possible), learning new things, kite-surfing.
    Im planning a trip to climb Denali in Alaska next year having climbed and skied off Mont Blanc in the spring of 2023 when I lived in Chamonix.
    If they ask whether aliens are real you can give them your answer. Whatever that is.
    If they ask a question you can't answer based on the above. Tell them 'I'm sorry, my responses are limited. You must ask the right questions.' And then say 'For your trouble, here is a quotation I hope you find interesting' and then give them a quote of you choice.
  "
  @tomo_cv "
    For any questions relating to my CV or Resume, please answer based on the following information:
    Profile
    Passionate software engineer open to full stack or backend roles using Elixir. Experience in startup and corporate environments as well as previous work in the London insurance market, where I started programming. Here I learned Python and the quantitative and analytical skills that transferred well into the software engineering industry
    Employment History
    Role: Elixir Full Stack Engineer, Vibrant Planet, May 2024 - June 2025
    Vibrant Planet is a climate technology company working on wildfire resilience in the USA. Working as a full stack Elixir engineer there working in a geospatial data heavy environment.
    Role: Elixir Full Stack Engineer, Independent, Feb 2023 - Jan 2024
    Various freelance projects using the PETAL stack. Currently working on a greenfield webs application for an events company using Phoenix LiveView and Elixir - its in beta.
    Built a highly performant webscraper for an Australian fnancial services client using sentiment analysis and named entity recognition. This resulted in a 50% improvement in their latency metrics.
    Role: Senior Javascript Developer Contract, MMT Digital June 2022 - Jan 2023
    Developed a portolio management mobile application for a global wealth management firm on a contractual basis
    Reviewed code of other developers and participated in overall design decisions and reviews helping estimate project scope and functionality
    Built REST endpoints and client side queries for mobile application. Worked with remote teams across different time zones
    Role: Full Stack Engineer, Tiso App Jul 2019 - May 2022 London
    Muilt social platorm centred around events using React Native, RealmDM (for offline functionality), GraphQL, and Node.js with MongoDB database
    Used containerised backend using Docker and Kubernetes as well as establishing a CI/CD pipeline with Fastlane and Github actions
    Migrated the websocket mechanism for instant messaging from Node.js to Elixir by utilising Phoenix channels
    Role: Reinsurance Broker, Price Forbes & Partners Dec 2011 - Feb 2018 City of London
    Managed various aspects of teams analytics using Python and tools like Numpy and pandas - this included modelling exposures and pricing
    Headed Gulf of mexico wind portolio with an exposure of $80m for leading London syndicate which brought in £250k revenue for the team
    Education
    University of Newcastle upon Tyne,Economics & Politics - Upper Second Sep 2007 - July 2010
    CFA Institute, CFA level II - (90th percentile globally Jun 2016 - Jun 2018)
  "

  @impl true
  def mount(_params, _session, socket) do
    form_params = %{"question" => ""}

    socket =
      socket
      |> assign(:async_result, %AsyncResult{})
      |> assign(:form, to_form(form_params))
      |> assign(:response, nil)
      |> assign(:messages, [%{role: "user", content: "How old are you?"}])
      |> assign_llm_chain()

    {:ok, socket}
  end

  @impl true
  def handle_info({:chat_response, %MessageDelta{} = delta}, socket) do
    updated_chain = LLMChain.apply_delta(socket.assigns.llm_chain, delta)

    socket =
      cond do
        updated_chain.delta == nil ->
          assign(socket, :response, updated_chain.last_message.content)

        # this will complete if updated_chain.delta is not nil
        true ->
          socket
      end

    {:noreply, assign(socket, :llm_chain, updated_chain)}
  end

  @impl true
  def handle_event("submit", %{"question" => question}, socket) do
    messages = socket.assigns.messages ++ [%{role: "user", content: question}]

    socket =
      socket
      |> assign(:question, question)
      |> assign(:messages, messages)
      |> assign_llm_chain()
      |> run_chain()

    {:noreply, socket}
  end

  def run_chain(socket) do
    chain = socket.assigns.llm_chain
    lv_pid = self()

    callback_fn = fn
      %MessageDelta{} = delta ->
        send(lv_pid, {:chat_response, delta})

      %Message{} = _data ->
        :ok
    end

    socket
    |> assign(:async_result, AsyncResult.loading())
    |> start_async(:running_llm, fn ->
      case LLMChain.run(chain, callback_fn: callback_fn) do
        {:error, error} ->
          {:error, error}

        _ ->
          :ok
      end
    end)
  end

  # handles async function returning a successful result
  def handle_async(:running_llm, {:ok, :ok = _success_result}, socket) do
    # discard the result of the successful async function. We only want the side effects
    socket =
      assign(socket, :async_result, AsyncResult.ok(%AsyncResult{}, :ok))

    {:noreply, socket}
  end

  # handles async function returning an error as a result
  def handle_async(:running_llm, {:ok, {:error, reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, reason)
      |> assign(:async_result, AsyncResult.failed(%AsyncResult{}, reason))

    {:noreply, socket}
  end

  # handles async function exploding
  def handle_async(:running_llm, {:exit, reason}, socket) do
    socket =
      socket
      |> put_flash(:error, "Call failed: #{inspect(reason)}")
      |> assign(:async_result, %AsyncResult{})

    {:noreply, socket}
  end

  defp assign_llm_chain(socket) do
    messages = Messages.messages_to_langchain_messages(socket.assigns.messages)

    llm_chain =
      LLMChain.new!(%{
        llm:
          ChatOpenAI.new!(%{
            model: "gpt-3.5-turbo",
            stream: true
          }),
        verbose: false
      })
      |> LLMChain.add_messages([
        Message.new_system!(@tomo_info <> @tomo_cv)
      ])
      |> LLMChain.add_messages(messages)

    assign(socket, :llm_chain, llm_chain)
  end
end
