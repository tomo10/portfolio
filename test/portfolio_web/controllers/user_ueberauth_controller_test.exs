defmodule PortfolioWeb.UserUeberauthControllerTest do
  use PortfolioWeb.ConnCase, async: true
  alias Portfolio.Accounts.User
  alias Portfolio.Repo

  test "creates user from Google information", %{conn: conn} do
    user_info = %{
      credentials: %{token: "token"},
      info: %{email: "bob@example.com", first_name: "Bob", last_name: "Smith", image: "image.jpg"},
      provider: :google
    }

    conn =
      conn
      |> assign(:ueberauth_auth, user_info)
      |> get("/auth/google/callback")

    latest_user = Repo.last(User)
    assert latest_user.name == "#{user_info.info.first_name} #{user_info.info.last_name}"
    assert latest_user.avatar == user_info.info.image
    assert latest_user.email == user_info.info.email
    assert redirected_to(conn) == PortfolioWeb.Helpers.home_path(latest_user)
  end

  test "creates user from Github information", %{conn: conn} do
    user_info = %{
      credentials: %{token: "token"},
      info: %{email: "bob@example.com", name: "Bob Smith", image: "image.jpg"},
      provider: :github
    }

    conn =
      conn
      |> assign(:ueberauth_auth, user_info)
      |> get("/auth/github/callback")

    latest_user = Repo.last(User)
    assert latest_user.name == user_info.info.name
    assert latest_user.avatar == user_info.info.image
    assert latest_user.email == user_info.info.email
    assert redirected_to(conn) == PortfolioWeb.Helpers.home_path(latest_user)
  end
end
