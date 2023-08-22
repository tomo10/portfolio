defmodule Portfolio.Repo do
  use Ecto.Repo,
    otp_app: :portfolio,
    adapter: Ecto.Adapters.Postgres

  use PetalFramework.Extensions.Ecto.RepoExt
end
