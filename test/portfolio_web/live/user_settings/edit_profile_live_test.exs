defmodule PortfolioWeb.EditProfileLiveTest do
  use PortfolioWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Portfolio.Repo

  describe "when signed in" do
    setup :register_and_sign_in_user

    test "event update_profile works", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/app/users/edit-profile")
      assert html =~ "Name"

      assert view
             |> form("#update_profile_form", user: %{name: "123456789"})
             |> render_submit() =~ "Profile updated"

      user = Portfolio.Accounts.get_user!(user.id)
      assert user.name == "123456789"

      log = Repo.last(Portfolio.Logs.Log)
      assert log.user_id == user.id
      assert log.action == "update_profile"
    end

    test "user can remove their avatar", %{conn: conn, user: user} do
      {:ok, user} = Portfolio.Accounts.update_profile(user, %{avatar: "avatar"})
      assert user.avatar == "avatar"

      {:ok, view, _html} = live(conn, ~p"/app/users/edit-profile")

      view
      |> element(~s|[phx-click="clear_avatar"]|)
      |> render_click()

      user = Portfolio.Accounts.get_user!(user.id)
      assert is_nil(user.avatar)
    end
  end

  describe "when signed out" do
    test "can't access the page", %{conn: conn} do
      live(conn, ~p"/app/users/edit-profile")
      |> assert_route_protected()
    end
  end
end
