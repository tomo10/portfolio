defmodule PortfolioWeb.UserSettingsController do
  use PortfolioWeb, :controller

  alias Portfolio.Accounts
  alias Portfolio.Accounts.NotificationSubscriptions
  alias PortfolioWeb.UserAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update_password(conn, params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Password updated successfully."))
        |> put_session(:user_return_to, ~p"/app/users/change-password")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        conn
        |> put_flash(
          :error,
          PortfolioWeb.CoreComponents.combine_changeset_error_messages(changeset)
        )
        |> redirect(to: ~p"/app/users/change-password")
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        Accounts.user_lifecycle_action(
          "after_confirm_new_email",
          Accounts.get_user!(conn.assigns.current_user.id)
        )

        conn
        |> put_flash(:info, gettext("Email changed successfully."))
        |> redirect(to: ~p"/app/users/edit-profile")

      :error ->
        conn
        |> put_flash(:error, gettext("Email change link is invalid or it has expired."))
        |> redirect(to: ~p"/app/users/edit-profile")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

  def unsubscribe_from_notification_subscription(conn, %{
        "code" => code,
        "notification_subscription" => notification_subscription
      }) do
    user = Accounts.get_user!(Util.HashId.decode(code))

    case NotificationSubscriptions.get(notification_subscription) do
      nil ->
        redirect(conn, to: "/")

      subscription ->
        render(
          conn,
          "unsubscribe_from_notification_subscription.html",
          user: user,
          code: code,
          subscription: subscription
        )
    end
  end

  def toggle_notification_subscription(conn, %{
        "code" => code,
        "notification_subscription" => notification_subscription
      }) do
    user = Accounts.get_user!(Util.HashId.decode(code))

    case NotificationSubscriptions.toggle_user_subscription(user, notification_subscription) do
      true ->
        redirect(conn,
          to: ~p"/unsubscribe/#{code}/#{notification_subscription}"
        )

      false ->
        conn
        |> put_flash(:error, gettext("Invalid link"))
        |> redirect(to: "/")
    end
  end

  def unsubscribe_from_mailbluster(conn, %{"email" => email}) do
    user = Accounts.get_user_by_email(Util.trim(email))
    subscription = Enum.find(NotificationSubscriptions.list(), & &1[:sent_by_mailbluster])

    if user && subscription do
      NotificationSubscriptions.toggle_user_subscription(user, subscription.name)
    end

    redirect(conn, to: ~p"/unsubscribe/marketing")
  end

  def mailbluster_unsubscribed_confirmation(conn, _params) do
    render(conn)
  end
end
