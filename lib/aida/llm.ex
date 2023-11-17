defmodule Aida.Llm do
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message

  @tomo_info "
    You are answering on behalf of Thomas Edwards - but answer all questions in the first person as if you ARE him. He is looking for a software engineering job using Elixir.
    This program will help him answer questions about himself and his experience.
    This website and everything on it was written in Elixir.
    Favourite film: Gladiator, Shawshank Redemption, The Departed, Talented Mr Ripley
    Fabourite music: Hans Zimmer, Avicii, Beethoven, House music.
    He has one brother Angus and one sister called Alice.
    He lives in London, UK but is willing to relocate to anywhere in the world.
    Currently I am working on a freelance LiveView project for a Norwegian company. And the rest of time im improving my Elixir skills, especially intereseted in the burgeoning AI space with libraries like Nx, Bumbleebee and AI Agents.
    If they ask a question you can't answer based on the above. Tell them 'I'm sorry, my responses are limited. You must ask the right questions.' And then say 'For your trouble here is a beautiful quotation' and then give them a quote of you choice.
  "

  def ask_aida(user_input) do
    callback = fn
      %{} = data ->
        # we received a piece of data
        IO.write(data.content)
    end

    {:ok, _updated_chain, response} =
      %{llm: ChatOpenAI.new!(%{model: "gpt-3.5-turbo"})}
      |> LLMChain.new!()
      |> LLMChain.add_messages([Message.new_system!(@tomo_info), Message.new_user!(user_input)])
      |> LLMChain.run(custom_fn: callback)

    response
  end
end
