defmodule PortfolioWeb.CheckConfigPlug do
  import Plug.Conn
  use Phoenix.Controller

  def init(options), do: options

  def call(conn, opts) do
    if Portfolio.config(opts[:config_key]) do
      conn
    else
      conn
      |> redirect(to: opts[:else])
      |> halt()
    end
  end
end
