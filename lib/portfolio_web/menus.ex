defmodule PortfolioWeb.Menus do
  @moduledoc """
  Describe all of your navigation menus in here. This keeps you from having to define them in a layout template
  """
  import PortfolioWeb.Gettext
  use PortfolioWeb, :verified_routes

  # Public menu (marketing related pages)
  def public_menu_items(_user \\ nil),
    do: [
      %{label: gettext("Projects"), path: "/#projects"},
      %{label: gettext("Contact"), path: "/#contact"}
    ]

  # Signed out main menu
  def main_menu_items(nil),
    do: []
end
