defmodule PortfolioWeb.OrgsLiveTest do
  use PortfolioWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Portfolio.Repo

  setup :register_and_sign_in_user

  describe ":index action" do
    test "show orgs the user is a member of", %{conn: conn, org: org} do
      {:ok, _view, html} = live(conn, ~p"/app/orgs")
      assert html =~ org.name
    end
  end

  describe ":new action" do
    test "with valid params will create a new org ", %{conn: conn, org: _org, user: _user} do
      {:ok, view, html} = live(conn, ~p"/app/orgs/new")

      assert html =~ "New organization"

      {:ok, _view, html} =
        view
        |> form("form", org: %{name: "Acme Inc."})
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/orgs")

      assert html =~ "Acme Inc."

      org = Repo.last(Portfolio.Orgs.Org)
      assert org.name == "Acme Inc."
      assert org.slug == "acme-inc"
    end

    test "with invalid params shows errors", %{conn: conn, org: _org, user: _user} do
      {:ok, view, _html} = live(conn, ~p"/app/orgs/new")

      assert view
             |> form("form")
             |> render_change(%{org: %{name: "d"}}) =~ "should be at least 2 character"
    end
  end
end
