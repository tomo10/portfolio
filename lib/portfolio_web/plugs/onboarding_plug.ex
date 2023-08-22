defmodule PortfolioWeb.OnboardingPlug do
  @moduledoc """
  This plug shows an onboarding screen for new users.
  Good for either collecting more details or showing a welcome screen.
  To remove:
    1. Search router.ex for "OnboardingPlug" and delete them
    2. Now users won't have to onboard. However, if a user registers via passwordless auth, they won't have a name.
  """
  import Plug.Conn
  use Phoenix.Controller
  use PortfolioWeb, :verified_routes

  def init(options), do: options

  def call(conn, _opts) do
    if conn.assigns[:current_user] && !conn.assigns.current_user.is_onboarded &&
         !is_onboarding_path?(conn) do
      conn
      |> redirect(to: ~p"/app/users/onboarding?#{[user_return_to: current_path(conn)]}")
      |> halt()
    else
      conn
    end
  end

  def is_onboarding_path?(conn) do
    conn.request_path == ~p"/app/users/onboarding"
  end
end
