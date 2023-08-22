defmodule PortfolioWeb.UserTOTPControllerTest do
  use PortfolioWeb.ConnCase, async: true

  import Portfolio.AccountsFixtures
  @pending :user_totp_pending

  setup %{conn: conn} do
    user = confirmed_user_fixture(%{is_onboarded: true})
    conn = conn |> log_in_user(user) |> put_session(@pending, true)
    %{user: user, totp: user_totp_fixture(user), conn: conn}
  end

  describe "GET /users/totp" do
    test "renders totp page", %{conn: conn} do
      conn = get(conn, ~p"/app/users/totp")
      response = html_response(conn, 200)
      assert response =~ "Two-factor authentication"
    end

    test "reads remember from URL", %{conn: conn} do
      conn = get(conn, ~p"/app/users/totp", user: [remember_me: "true"])
      response = html_response(conn, 200)

      assert response =~ "checkbox"
      assert response =~ "user[remember_me]"
    end

    test "redirects to login if not logged in" do
      conn = build_conn()

      assert conn
             |> get(~p"/app/users/totp")
             |> redirected_to() ==
               ~p"/auth/sign-in"
    end

    test "can sign out while totp is pending", %{conn: conn} do
      conn = delete(conn, ~p"/auth/sign-out")
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Signed out successfully"
    end

    test "redirects to dashboard if totp is not pending", %{conn: conn, user: user} do
      assert conn
             |> delete_session(@pending)
             |> get(~p"/app/users/totp")
             |> redirected_to() ==
               PortfolioWeb.Helpers.home_path(user)
    end
  end

  describe "POST /users/totp" do
    test "validates totp", %{conn: conn, totp: totp, user: user} do
      code = NimbleTOTP.verification_code(totp.secret)
      conn = post(conn, ~p"/app/users/totp", %{"user" => %{"code" => code}})
      assert_log("totp.validate", user_id: user.id)
      assert redirected_to(conn) == PortfolioWeb.Helpers.home_path(user)
      assert get_session(conn, @pending) == nil
    end

    test "validates backup code with flash message", %{conn: conn, totp: totp, user: user} do
      code = Enum.random(totp.backup_codes).code

      new_conn = post(conn, ~p"/app/users/totp", %{"user" => %{"code" => code}})
      assert redirected_to(new_conn) == PortfolioWeb.Helpers.home_path(user)
      assert get_session(new_conn, @pending) == nil
      assert Phoenix.Flash.get(new_conn.assigns.flash, :info) =~ "You have 9 backup codes left"
      assert_log("totp.validate_with_backup_code", user_id: user.id)

      # Cannot reuse the code
      new_conn = post(conn, ~p"/app/users/totp", %{"user" => %{"code" => code}})
      assert html_response(new_conn, 200) =~ "Invalid two-factor authentication code"
      assert get_session(new_conn, @pending)
      assert_log("totp.invalid_code_used", user_id: user.id)
    end

    test "logs the user in with remember me", %{conn: conn, totp: totp, user: user} do
      code = Enum.random(totp.backup_codes).code

      conn =
        post(conn, ~p"/app/users/totp", %{
          "user" => %{"code" => code, "remember_me" => "true"}
        })

      assert redirected_to(conn) == PortfolioWeb.Helpers.home_path(user)
      assert get_session(conn, @pending) == nil
      assert conn.resp_cookies["_portfolio_web_user_remember_me"]
    end

    test "logs the user in with return to", %{conn: conn, totp: totp} do
      code = Enum.random(totp.backup_codes).code

      conn =
        conn
        |> put_session(:user_return_to, "/hello")
        |> post(~p"/app/users/totp", %{"user" => %{"code" => code}})

      assert redirected_to(conn) == "/hello"
      assert get_session(conn, @pending) == nil
    end
  end
end
