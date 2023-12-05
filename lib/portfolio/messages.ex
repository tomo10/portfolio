defmodule Portfolio.Messages do
  @doc """
  Convert a regular message to a LangChain Message struct.
  """
  def messages_to_langchain_messages(messages) do
    Enum.map(messages, fn msg ->
      LangChain.Message.new!(%{
        role: msg.role,
        content: msg.content
      })
    end)
  end
end
