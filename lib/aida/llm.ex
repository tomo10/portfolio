defmodule Aida.Llm do
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message

  def test_aida do
    {:ok, _updated_chain, response} =
      %{llm: ChatOpenAI.new!(%{model: "gpt-3.5-turbo"})}
      |> LLMChain.new!()
      |> LLMChain.add_message(
        Message.new_user!(
          "Hello world, I'm AIDA Thomas' artificially intelligent digital assistant."
        )
      )
      |> LLMChain.run()

    response
  end
end
