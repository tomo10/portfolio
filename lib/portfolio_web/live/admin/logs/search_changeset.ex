defmodule PortfolioWeb.LogsLive.SearchChangeset do
  import Ecto.Changeset

  def build(params) do
    data = %{}

    types = %{
      action: :string,
      user_id: :integer,
      enable_live_logs: :boolean
    }

    cast({data, types}, params, Map.keys(types))
  end

  def validate(changeset) do
    apply_action(changeset, :validate)
  end
end
