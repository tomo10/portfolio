alias Portfolio.Accounts
alias Portfolio.Accounts.User
alias Portfolio.Accounts.UserNotifier
alias Portfolio.Accounts.UserQuery
alias Portfolio.Accounts.UserSeeder
alias Portfolio.Accounts.UserSeeder
alias Portfolio.Logs
alias Portfolio.Logs.Log
alias Portfolio.MailBluster
alias Portfolio.Orgs
alias Portfolio.Orgs.Invitation
alias Portfolio.Orgs.Membership
alias Portfolio.Slack

# Don't cut off inspects with "..."
IEx.configure(inspect: [limit: :infinity])

# Allow copy to clipboard
# eg:
#    iex(1)> Phoenix.Router.routes(PortfolioWeb.Router) |> Helpers.copy
#    :ok
defmodule Helpers do
  def copy(term) do
    text =
      if is_binary(term) do
        term
      else
        inspect(term, limit: :infinity, pretty: true)
      end

    port = Port.open({:spawn, "pbcopy"}, [])
    true = Port.command(port, text)
    true = Port.close(port)

    :ok
  end
end
