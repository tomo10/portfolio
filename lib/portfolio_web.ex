defmodule PortfolioWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use PortfolioWeb, :controller
      use PortfolioWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts uploads images favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: PortfolioWeb,
        formats: [:html, :json],
        layouts: [html: PortfolioWeb.Layouts]

      import Plug.Conn
      import PortfolioWeb.Gettext
      import Phoenix.Component, only: [to_form: 2]

      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      use Phoenix.View,
        root: "lib/portfolio_web/templates",
        namespace: PortfolioWeb

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      unquote(html_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PortfolioWeb.Layouts, :app}

      # on_mount({PortfolioWeb.UserOnMountHooks, :maybe_assign_user})
      on_mount(PortfolioWeb.RestoreLocaleHook)
      on_mount(PortfolioWeb.AllowEctoSandboxHook)
      on_mount({PortfolioWeb.ViewSetupHook, :reset_page_title})

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent, global_prefixes: ~w(x-)

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component, global_prefixes: ~w(x-)

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import PortfolioWeb.CoreComponents
      import PortfolioWeb.Gettext
      use PetalComponents
      use PetalFramework

      import PortfolioWeb.Helpers

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import PortfolioWeb.Gettext
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PortfolioWeb.Endpoint,
        router: PortfolioWeb.Router,
        statics: PortfolioWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
