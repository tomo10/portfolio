defmodule PortfolioWeb.Router do
  use PortfolioWeb, :router
  import PortfolioWeb.UserAuth
  import PortfolioWeb.OrgPlugs
  import Phoenix.LiveDashboard.Router
  alias PortfolioWeb.OnboardingPlug
  import PortfolioWeb.UserImpersonationController

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

    plug :fetch_current_user
    plug :fetch_impersonator_user
    plug :kick_user_if_suspended_or_deleted
    plug PetalFramework.SetLocalePlug, gettext: PortfolioWeb.Gettext
  end

  pipeline :public_layout do
    plug :put_layout, html: {PortfolioWeb.Layouts, :public}
  end

  pipeline :authenticated do
    plug :require_authenticated_user
    plug OnboardingPlug
    plug :assign_org_data
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

  # App routes - for signed in and confirmed users only
  scope "/app", PortfolioWeb do
    pipe_through [:browser, :authenticated]

    # Add controller authenticated routes here
    put "/users/settings/update-password", UserSettingsController, :update_password
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
    get "/users/totp", UserTOTPController, :new
    post "/users/totp", UserTOTPController, :create

    live_session :authenticated,
      on_mount: [
        {PortfolioWeb.UserOnMountHooks, :require_authenticated_user},
        {PortfolioWeb.OrgOnMountHooks, :assign_org_data}
      ] do
      # Add live authenticated routes here
      live "/", DashboardLive
      live "/users/onboarding", UserOnboardingLive
      live "/users/edit-profile", EditProfileLive
      live "/users/edit-email", EditEmailLive
      live "/users/change-password", EditPasswordLive
      live "/users/edit-notifications", EditNotificationsLive
      live "/users/org-invitations", UserOrgInvitationsLive
      live "/users/two-factor-authentication", EditTotpLive

      live "/orgs", OrgsLive, :index
      live "/orgs/new", OrgsLive, :new

      scope "/org/:org_slug" do
        live "/", OrgDashboardLive
        live "/edit", EditOrgLive
        live "/team", OrgTeamLive, :index
        live "/team/invite", OrgTeamLive, :invite
        live "/team/memberships/:id/edit", OrgTeamLive, :edit_membership
      end
    end
  end

  use PortfolioWeb.AuthRoutes

  if Portfolio.config(:impersonation_enabled?) do
    use PortfolioWeb.AuthImpersonationRoutes
  end

  use PortfolioWeb.MailblusterRoutes
  use PortfolioWeb.AdminRoutes

  # DevRoutes must always be last
  use PortfolioWeb.DevRoutes
end
