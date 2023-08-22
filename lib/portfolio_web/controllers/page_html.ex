defmodule PortfolioWeb.PageHTML do
  use PortfolioWeb, :html
  alias PortfolioWeb.Components.LandingPage

  embed_templates "page_html/*"
end
