defmodule PortfolioWeb.AuthImpersonationRoutes do
  defmacro __using__(_) do
    quote do
      scope "/auth", PortfolioWeb do
        pipe_through [:browser, :require_admin_user]

        post "/impersonate", UserImpersonationController, :create
      end

      scope "/auth", PortfolioWeb do
        pipe_through [:browser, :require_authenticated_user]

        delete "/impersonate", UserImpersonationController, :delete
      end
    end
  end
end
