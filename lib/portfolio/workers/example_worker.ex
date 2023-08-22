defmodule Portfolio.Workers.ExampleWorker do
  @moduledoc """
  Example of how to do async work with Oban.

  Run with:
  Oban.insert(Portfolio.Workers.ExampleWorker.new(%{}))
  """
  use Oban.Worker, queue: :default
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{} = _job) do
    today = Timex.to_date(Timex.now())
    Logger.info("ExampleWorker: Today is #{today}")
    :ok
  end

  # Example with arguments (run with Oban.insert(Portfolio.Workers.ExampleWorker.new(%{id: 1})))
  # @impl Oban.Worker
  # def perform(%Oban.Job{args: %{"id" => id} = args}) do
  #   Logger.info("ExampleWorker: ID is #{id}")
  #   :ok
  # end
end
