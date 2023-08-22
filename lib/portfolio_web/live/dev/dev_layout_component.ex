defmodule PortfolioWeb.DevLayoutComponent do
  @moduledoc """
  A layout for any user setting screen like "Change email", "Change password" etc
  """
  use PortfolioWeb, :component

  attr :current_user, :map
  attr :current_page, :atom
  slot(:inner_block)

  def dev_layout(assigns) do
    ~H"""
    <.layout
      current_page={@current_page}
      current_user={@current_user}
      type="sidebar"
      main_menu_items={[
        %{
          title: "Pages",
          menu_items: [
            PortfolioWeb.Menus.get_link(:dev, @current_user),
            PortfolioWeb.Menus.get_link(:dev_resources, @current_user)
          ]
        },
        %{
          title: "Emails",
          menu_items:
            PortfolioWeb.Menus.build_menu([:dev_email_templates, :dev_sent_emails], @current_user)
        }
      ]}
    >
      <%= render_slot(@inner_block) %>
    </.layout>
    """
  end
end
