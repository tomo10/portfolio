defmodule Portfolio.Repo.Migrations.AddOrgsToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add(:org_id, references(:orgs, on_delete: :delete_all))
    end

    create(index(:logs, [:org_id]))
  end
end
