defmodule PortfolioWeb.DevDashboardLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.DevLayoutComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Dev")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <DevLayoutComponent.dev_layout current_page={:dev} current_user={@current_user}>
      <.container class="py-16">
        <div class="ml-[60px]">
          <.h2><%= Portfolio.config(:app_name) %></.h2>
          <.p>A list of your apps routes. Click one to copy its helper.</.p>
        </div>
        <.route_tree router={PortfolioWeb.Router} />
      </.container>
    </DevLayoutComponent.dev_layout>
    """
  end
end
