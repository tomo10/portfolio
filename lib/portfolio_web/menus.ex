defmodule PortfolioWeb.Menus do
  @moduledoc """
  Describe all of your navigation menus in here. This keeps you from having to define them in a layout template
  """
  import PortfolioWeb.Gettext
  use PortfolioWeb, :verified_routes
  alias PortfolioWeb.Helpers

  # Public menu (marketing related pages)
  def public_menu_items(_user \\ nil),
    do: [
      %{label: gettext("Projects"), path: "/#projects"},
      %{label: gettext("Contact"), path: "/#contact"}
    ]

  # Signed out main menu
  def main_menu_items(nil),
    do: []

  # Signed in main menu
  def main_menu_items(current_user),
    do:
      build_menu(
        [
          :dashboard,
          :orgs
        ],
        current_user
      )

  # Signed out user menu
  def user_menu_items(nil),
    do:
      build_menu(
        [
          :sign_in,
          :register
        ],
        nil
      )

  # Signed in user menu
  def user_menu_items(current_user),
    do:
      build_menu(
        [
          :dashboard,
          :settings,
          :admin,
          :dev,
          :sign_out
        ],
        current_user
      )

  def build_menu(menu_items, current_user \\ nil) do
    Enum.map(menu_items, fn menu_item ->
      cond do
        is_atom(menu_item) ->
          get_link(menu_item, current_user)

        is_map(menu_item) ->
          Map.merge(
            get_link(menu_item.name, current_user),
            menu_item
          )
      end
    end)
    |> Enum.filter(& &1)
  end

  def get_link(name, current_user \\ nil)

  def get_link(:register = name, _current_user) do
    %{
      name: name,
      label: gettext("Register"),
      path: ~p"/auth/register",
      icon: :clipboard_document_list
    }
  end

  def get_link(:sign_in = name, _current_user) do
    %{
      name: name,
      label: gettext("Sign in"),
      path: ~p"/auth/sign-in",
      icon: :key
    }
  end

  def get_link(:sign_out = name, current_user) do
    if current_user.current_impersonator do
      %{
        name: name,
        label: gettext("Exit impersonation"),
        path: ~p"/auth/impersonate",
        icon: :arrow_right_on_rectangle,
        method: :delete
      }
    else
      %{
        name: name,
        label: gettext("Sign out"),
        path: ~p"/auth/sign-out",
        icon: :arrow_right_on_rectangle,
        method: :delete
      }
    end
  end

  def get_link(:settings = name, _current_user) do
    %{
      name: name,
      label: gettext("Settings"),
      path: ~p"/app/users/edit-profile",
      icon: :cog
    }
  end

  def get_link(:edit_profile = name, _current_user) do
    %{
      name: name,
      label: gettext("Edit profile"),
      path: ~p"/app/users/edit-profile",
      icon: :user_circle
    }
  end

  def get_link(:edit_email = name, _current_user) do
    %{
      name: name,
      label: gettext("Change email"),
      path: ~p"/app/users/edit-email",
      icon: :at_symbol
    }
  end

  def get_link(:edit_notifications = name, _current_user) do
    %{
      name: name,
      label: gettext("Edit notifications"),
      path: ~p"/app/users/edit-notifications",
      icon: :bell
    }
  end

  def get_link(:edit_password = name, _current_user) do
    %{
      name: name,
      label: gettext("Edit password"),
      path: ~p"/app/users/change-password",
      icon: :key
    }
  end

  def get_link(:org_invitations = name, _current_user) do
    %{
      name: name,
      label: gettext("Invitations"),
      path: ~p"/app/users/org-invitations",
      icon: :envelope
    }
  end

  def get_link(:edit_totp = name, _current_user) do
    %{
      name: name,
      label: gettext("2FA"),
      path: ~p"/app/users/two-factor-authentication",
      icon: :shield_check
    }
  end

  def get_link(:dashboard = name, _current_user) do
    %{
      name: name,
      label: gettext("Dashboard"),
      path: ~p"/app",
      icon: :rectangle_group
    }
  end

  def get_link(:orgs = name, _current_user) do
    %{
      name: name,
      label: gettext("Organizations"),
      path: ~p"/app/orgs",
      icon: :building_office
    }
  end

  def get_link(:admin, current_user) do
    link = get_link(:admin_users, current_user)

    if link do
      link
      |> Map.put(:label, gettext("Admin"))
      |> Map.put(:icon, :lock_closed)
    end
  end

  def get_link(:admin_users = name, current_user) do
    if Helpers.is_admin?(current_user) do
      %{
        name: name,
        label: gettext("Users"),
        path: ~p"/admin/users",
        icon: :users
      }
    end
  end

  def get_link(:admin_logs = name, current_user) do
    if Helpers.is_admin?(current_user) do
      %{
        name: name,
        label: gettext("Logs"),
        path: ~p"/admin/logs",
        icon: :eye
      }
    end
  end

  def get_link(:admin_jobs = name, current_user) do
    if Helpers.is_admin?(current_user) do
      %{
        name: name,
        label: gettext("Jobs"),
        path: ~p"/admin/jobs",
        icon: :server
      }
    end
  end

  def get_link(:dev = name, _current_user) do
    if Portfolio.config(:env) == :dev do
      %{
        name: name,
        label: gettext("Dev"),
        path: "/dev",
        icon: :code_bracket
      }
    end
  end

  def get_link(:dev_email_templates = name, _current_user) do
    if Portfolio.config(:env) == :dev do
      %{
        name: name,
        label: gettext("Email templates"),
        path: "/dev/emails",
        icon: :rectangle_group
      }
    end
  end

  def get_link(:dev_sent_emails = name, _current_user) do
    if Portfolio.config(:env) == :dev do
      %{
        name: name,
        label: gettext("Sent emails"),
        path: "/dev/emails/sent",
        icon: :at_symbol
      }
    end
  end

  def get_link(:dev_resources = name, _current_user) do
    if Portfolio.config(:env) == :dev do
      %{
        name: name,
        label: gettext("Resources"),
        path: ~p"/dev/resources",
        icon: :clipboard_document_list
      }
    end
  end
end
