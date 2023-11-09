defmodule PortfolioWeb.Helpers do
  use PortfolioWeb, :verified_routes

  @moduledoc """
  A set of helpers used in web related views and templates. These functions can be called anywhere in a heex template.
  """
  def home_path(nil), do: "/"

  # Always use this when rendering a user's name
  # This way, if you want to change to something like "user.first_name user.last_name", you only have to change one place
  def user_name(nil), do: nil
  def user_name(user), do: user.name

  def user_avatar_url(nil), do: nil
  def user_avatar_url(user), do: user.avatar

  def is_admin?(%{is_admin: true}), do: true
  def is_admin?(_), do: false

  def format_date(date, format \\ "{ISOdate}"), do: Timex.format!(date, format)

  # Autofocuses the input
  # <input {alpine_autofocus()} />
  def alpine_autofocus() do
    %{
      "x-data": "",
      "x-init": "$nextTick(() => { $el.focus() });"
    }
  end

  @doc """
  When you want to display code in a heex template, you can use this helper to escape it.
  """
  def code_block(code) do
    Phoenix.HTML.raw("""
    <pre>#{code}</pre>
    """)
  end
end
