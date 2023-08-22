defmodule PortfolioWeb.OrgPlugs do
  import Plug.Conn
  import Phoenix.Controller
  import PortfolioWeb.Gettext

  use PortfolioWeb, :verified_routes

  def assign_org_data(conn, _opts) do
    org_slug = conn.params["org_slug"]
    orgs = Portfolio.Orgs.list_orgs(conn.assigns.current_user)
    current_org = Enum.find(orgs, &(&1.slug == org_slug))

    if org_slug && !current_org do
      conn
      |> put_flash(:error, gettext("You do not have permission to access this page."))
      |> redirect(to: ~p"/app/orgs")
      |> halt()
    else
      current_membership =
        org_slug && Portfolio.Orgs.get_membership!(conn.assigns.current_user, org_slug)

      conn
      |> assign(:orgs, orgs)
      |> assign(:current_membership, current_membership)
      |> assign(:current_org, current_org)
    end
  end

  # Must be run after :assign_org_data
  def require_org_member(conn, _opts) do
    membership = conn.assigns.current_membership

    if membership do
      conn
    else
      conn
      |> put_flash(:error, gettext("You do not have permission to access this page."))
      |> redirect(to: PortfolioWeb.Helpers.home_path(conn.assigns.current_user))
      |> halt()
    end
  end

  # Must be run after :assign_org_data
  def require_org_admin(conn, _opts) do
    membership = conn.assigns.current_membership

    if membership.role == :admin do
      conn
    else
      conn
      |> put_flash(:error, gettext("You do not have permission to access this page."))
      |> redirect(to: PortfolioWeb.Helpers.home_path(conn.assigns.current_user))
      |> halt()
    end
  end
end
