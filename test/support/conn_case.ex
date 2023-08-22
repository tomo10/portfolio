defmodule PortfolioWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PortfolioWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  alias PetalFramework.Extensions.Ecto.QueryExt

  using do
    quote do
      # The default endpoint for testing
      @endpoint PortfolioWeb.Endpoint

      use PortfolioWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import PortfolioWeb.ConnCase
      import Swoosh.TestAssertions
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Portfolio.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_sign_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_sign_in_user(%{conn: conn}) do
    user = Portfolio.AccountsFixtures.confirmed_user_fixture(%{is_onboarded: true})
    org = Portfolio.OrgsFixtures.org_fixture(user)
    membership = Portfolio.Orgs.get_membership!(user, org.slug)
    %{conn: log_in_user(conn, user), user: user, org: org, membership: membership}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  @spec log_in_user(Plug.Conn.t(), Portfolio.Accounts.user()) :: Plug.Conn.t()
  def log_in_user(conn, user) do
    token = Portfolio.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  @doc """
  Impersonates the given `user` (for the `impersonator_user`) into the `conn`.

  It returns an updated `conn`.
  """
  def impersonate_user(conn, impersonator_user, user) do
    user_token = Portfolio.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, user_token)
    |> Plug.Conn.put_session(:impersonator_user_id, impersonator_user.id)
  end

  @doc """
  This function tests that the route can't be accessed by an anonymous user.
  """
  def assert_route_protected(live_result) do
    {:error, {:redirect, %{flash: flash, to: to}}} = live_result
    assert flash["error"] =~ "You must sign in to access this page"
    assert to =~ "/auth/sign-in"
  end

  def assert_log(action, params \\ %{}) do
    log =
      Portfolio.Logs.LogQuery.by_action(action)
      |> Portfolio.Logs.LogQuery.order_by(:newest)
      |> QueryExt.limit(1)
      |> Portfolio.Repo.one()

    assert !!log, ~s|No log found for action "#{action}"|

    Enum.each(params, fn {k, v} ->
      assert(
        Map.get(log, k) == v,
        "log.#{k} should equal #{inspect(v)}, but it equals #{inspect(Map.get(log, k))} \n\n #{inspect(log)}"
      )
    end)
  end
end
