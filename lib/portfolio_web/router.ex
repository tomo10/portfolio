defmodule PortfolioWeb.Router do
  use PortfolioWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PortfolioWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        ContentSecurityPolicy.serialize(
          struct(ContentSecurityPolicy.Policy, Portfolio.config(:content_security_policy))
        )
    }

    plug PetalFramework.SetLocalePlug, gettext: PortfolioWeb.Gettext
  end

  pipeline :public_layout do
    plug :put_layout, html: {PortfolioWeb.Layouts, :public}
  end

  # Public routes
  scope "/", PortfolioWeb do
    pipe_through [:browser, :public_layout]

    # Add public controller routes here
    get "/", PageController, :landing_page
    get "/privacy", PageController, :privacy
    get "/license", PageController, :license
    get "/articles/:slug", PageController, :articles

    live_session :public, layout: {PortfolioWeb.Layouts, :public} do
      # Add public live routes here
      live "/ad-astra", AdAstraLive, :index
      live "/ad-astra/modal", AdAstraLive, :modal
    end
  end
end
