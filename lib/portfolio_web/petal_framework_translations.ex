defmodule PortfolioWeb.PetalFrameworkTranslations do
  import PortfolioWeb.Gettext

  def text("Showing"), do: gettext("Showing")
  def text("to"), do: gettext("to")
  def text("of"), do: gettext("of")
  def text("rows"), do: gettext("rows")
  def text("Equals"), do: gettext("Equals")
  def text("Not equal"), do: gettext("Not equal")
  def text("Search (case insensitive)"), do: gettext("Search (case insensitive)")
  def text("Is empty"), do: gettext("Is empty")
  def text("Not empty"), do: gettext("Not empty")
  def text("Less than or equals"), do: gettext("Less than or equals")
  def text("Less than"), do: gettext("Less than")
  def text("Greater than or equals"), do: gettext("Greater than or equals")
  def text("Greater than"), do: gettext("Greater than")
  def text("Search in"), do: gettext("Search in")
  def text("Contains"), do: gettext("Contains")
  def text("Search (case sensitive)"), do: gettext("Search (case sensitive)")
  def text("Search (case sensitive) (and)"), do: gettext("Search (case sensitive) (and)")
  def text("Search (case sensitive) (or)"), do: gettext("Search (case sensitive) (or)")
  def text("Search (case insensitive) (and)"), do: gettext("Search (case insensitive) (and)")
  def text("Search (case insensitive) (or)"), do: gettext("Search (case insensitive) (or)")

  def t(_), do: nil
end
