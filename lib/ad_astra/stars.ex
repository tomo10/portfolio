defmodule AdAstra.Stars do
  alias AdAstra.Stars.Star
  use Agent

  @doc """
  Starts a new agent / bucket
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{star_1: %Star{}, star_2: %Star{}} end, name: __MODULE__)
  end

  @doc """
  Gets a value from the 'bucket' by 'key'
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Gets the stars from the bucket
  """
  def stars do
    Agent.get(__MODULE__, fn map -> Map.values(map) end)
  end

  @doc """
  Puts the 'value' for the given 'key' in the 'bucket'
  """
  def put(key, value) do
    if value != nil do
      Agent.update(__MODULE__, &Map.put(&1, key, value))
    end
  end

  # def put(key, nil), do: nil

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking star chagnes
  """
  def change_star(%Star{} = star, attrs \\ %{}) do
    Star.changeset(star, attrs)
  end
end
