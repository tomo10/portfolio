defmodule PortfolioWeb.CustomComponents do
  use Phoenix.Component

  attr :name, :string
  attr :right_ascension, :integer
  attr :declination, :integer
  attr :distance_light_year, :integer

  def star(assigns) do
    ~H"""
    <%!-- <.h4>Star 2: <%= @name %></.h4> --%>
    <p>Right ascension: <%= @right_ascension %></p>
    <p>Declination: <%= @declination %></p>
    <p>Light years from Earth: <%= @distance_light_year %></p>
    """
  end
end
