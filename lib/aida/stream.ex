defmodule Aida.Stream do
  def subscribe do
    Phoenix.PubSub.subscribe(Portfolio.PubSub, "stream_response")
  end

  def broadcast(message) do
    Phoenix.PubSub.broadcast(Portfolio.PubSub, "stream_response", message)
  end
end
