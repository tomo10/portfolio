defmodule PortfolioWeb.UserImpersonationController do
  use PortfolioWeb, :controller

  alias Portfolio.Accounts
  alias PortfolioWeb.Helpers
  alias PortfolioWeb.UserAuth

  # Default rules for who can impersonate who. Modify this to what you'd like.
  defp can_impersonate?(impersonator_user, user) do
    impersonator_user.is_admin && !user.is_admin
  end

  def create(conn, %{"id" => id}) do
    impersonator_user = conn.assigns[:current_user]

    with user <- Accounts.get_user!(id), true <- can_impersonate?(impersonator_user, user) do
      conn
      |> put_flash(:info, gettext("Impersonating %{name}", name: Helpers.user_name(user)))
      |> impersonate_user(impersonator_user, user)
    else
      _ ->
        conn
        |> put_flash(:error, gettext("Invalid user or not permitted"))
        |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    if get_session(conn, :impersonator_user_id) do
      impersonator_user = Accounts.get_user!(get_session(conn, :impersonator_user_id))

      conn =
        conn
        |> delete_session(:impersonator_user_id)
        |> UserAuth.put_user_into_session(impersonator_user)

      Accounts.user_lifecycle_action("after_restore_impersonator", impersonator_user, %{
        ip: UserAuth.get_ip(conn),
        target_user_id: conn.assigns.current_user.id
      })

      # No need for MFA - `impersonator_user` was already logged in
      conn
      |> put_flash(
        :info,
        gettext("You're back as %{name}", name: Helpers.user_name(impersonator_user))
      )
      |> redirect(to: ~p"/admin/users")
    else
      redirect(conn, to: ~p"/")
    end
  end

  def impersonate_user(conn, impersonator_user, user) do
    conn =
      conn
      |> UserAuth.put_user_into_session(user)
      |> put_session(:impersonator_user_id, impersonator_user.id)

    Accounts.user_lifecycle_action("after_impersonate_user", impersonator_user, %{
      ip: UserAuth.get_ip(conn),
      target_user_id: user.id
    })

    # No need for MFA - `impersonator_user` was already logged in
    UserAuth.redirect_user_after_login_with_remember_me(conn, user)
  end

  @doc """
  Adds `:current_impersonator` to `conn.assigns.current_user` if `:impersonator_user_id` is set in the session.
  We put it on `:current_user` so that it's more easily accessible in templates.
  """
  def fetch_impersonator_user(conn, _opts) do
    case get_session(conn, :impersonator_user_id) do
      nil ->
        conn

      impersonator_user_id ->
        impersonator_user = Accounts.get_user!(impersonator_user_id)

        current_user =
          Map.put(conn.assigns.current_user, :current_impersonator, impersonator_user)

        assign(conn, :current_user, current_user)
    end
  end
end
