defmodule PortfolioWeb.DashboardLiveTest do
  use PortfolioWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_and_sign_in_user

  test "renders the user's name", %{conn: conn, user: user} do
    {:ok, _view, html} = live(conn, ~p"/app")
    assert html =~ user.name
  end
end
