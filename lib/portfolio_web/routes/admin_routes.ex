defmodule PortfolioWeb.AdminRoutes do
  defmacro __using__(_) do
    quote do
      scope "/admin", PortfolioWeb do
        pipe_through [:browser, :authenticated, :require_admin_user]

        live_dashboard "/server", metrics: PortfolioWeb.Telemetry

        live_session :require_admin_user,
          on_mount: [
            {PortfolioWeb.UserOnMountHooks, :require_admin_user}
          ] do
          live "/users", AdminUsersLive, :index
          live "/users/:user_id", AdminUsersLive, :edit
          live "/logs", LogsLive, :index
          live "/jobs", AdminJobsLive
        end
      end
    end
  end
end
