defmodule PortfolioWeb.LogsLive.LogDataTableSettings do
  use Ecto.Schema

  @moduledoc """
  Flop requires you to define settings on a schema file.
  To avoid polluting the schema file with Flop-specific code, we duplicate the schema here and add the Flop settings for the admin logs data table.

  While you could just put this in the schema file, we believe this is a better pattern in case you have multiple data tables for one schema. For example, you might have an admin data table and a user facing data table, which would have more restrictions.
  """

  @derive {
    Flop.Schema,
    filterable: [:id, :action, :user_type, :user_name, :user_id, :inserted_at],
    sortable: [:id, :action, :user_type, :user_name, :user_id, :inserted_at],
    default_order: %{
      order_by: [:inserted_at, :user_name, :action],
      order_directions: [:desc, :asc, :asc]
    },
    join_fields: [
      user_name: [binding: :user, field: :name],
      user_id: [binding: :user, field: :id]
    ]
  }

  schema "logs" do
    field :action, :string
    field :user_type, :string, default: "user"
    field :metadata, :map, default: %{}

    belongs_to :user, Portfolio.Accounts.User
    belongs_to :target_user, Portfolio.Accounts.User
    belongs_to :org, Portfolio.Orgs.Org

    timestamps(type: :utc_datetime)
  end
end
