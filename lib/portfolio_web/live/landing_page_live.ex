defmodule PortfolioWeb.LandingPageLive do
  use PortfolioWeb, :live_view
  alias PortfolioWeb.CustomComponents, as: CC

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
