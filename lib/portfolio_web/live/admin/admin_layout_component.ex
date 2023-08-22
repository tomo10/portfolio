defmodule PortfolioWeb.AdminLayoutComponent do
  use PortfolioWeb, :component
  use PetalComponents
  alias PortfolioWeb.Menus

  attr :current_user, :map, required: true
  attr :current_page, :atom
  slot(:inner_block)

  def admin_layout(assigns) do
    ~H"""
    <.layout
      current_page={@current_page}
      current_user={@current_user}
      type="sidebar"
      sidebar_title="Admin"
      main_menu_items={menu_items(@current_user)}
    >
      <.container max_width="xl" class="my-10">
        <%= render_slot(@inner_block) %>
      </.container>
    </.layout>
    """
  end

  def menu_items(current_user) do
    [
      %{
        title: "Admin",
        menu_items: [
          Menus.get_link(:admin_users, current_user),
          Menus.get_link(:admin_logs, current_user),
          Menus.get_link(:admin_jobs, current_user)
        ]
      },
      %{
        title: "Server",
        menu_items: [
          %{
            name: :server,
            label: gettext("Live dashboard"),
            path: ~p"/admin/server",
            icon: :chart_bar_square
          }
        ]
      }
    ]
  end
end
