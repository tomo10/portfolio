defmodule AdAstra.Stars.Star do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stars" do
    field :name, :string
    field :right_ascension, :string
    field :declination, :string
    field :distance_light_year, :integer
  end

  def changeset(star, attrs) do
    star
    |> cast(attrs, [:name, :right_ascension, :declination, :distance_light_year])
    |> validate_required([:name, :right_ascension, :declination, :distance_light_year])
  end
end
