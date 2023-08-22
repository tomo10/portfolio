# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Portfolio.Repo.insert!(%Portfolio.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Portfolio.Accounts.User
alias Portfolio.Accounts.UserSeeder
alias Portfolio.Accounts.UserToken
alias Portfolio.Accounts.UserTOTP
alias Portfolio.Logs.Log
alias Portfolio.Orgs.Org
alias Portfolio.Orgs.OrgSeeder

alias Portfolio.Orgs.Invitation
alias Portfolio.Orgs.Membership

if Mix.env() == :dev do
  Portfolio.Repo.delete_all(Log)
  Portfolio.Repo.delete_all(UserTOTP)
  Portfolio.Repo.delete_all(Invitation)
  Portfolio.Repo.delete_all(Membership)
  Portfolio.Repo.delete_all(Org)
  Portfolio.Repo.delete_all(UserToken)
  Portfolio.Repo.delete_all(User)

  admin = UserSeeder.admin()

  normal_user =
    UserSeeder.normal_user(%{
      email: "user@example.com",
      name: "Sarah Cunningham",
      password: "password",
      confirmed_at: Timex.to_naive_datetime(Timex.now())
    })

  org = OrgSeeder.random_org(admin)
  Portfolio.Orgs.create_invitation(org, %{email: normal_user.email})

  UserSeeder.random_users(20)
end
