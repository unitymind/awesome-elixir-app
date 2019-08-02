defmodule AwesomeElixir.Catalog.FilterParams do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :min_stars, :string, default: "all"
    field :show_unstarred, :boolean, default: false
    field :hide_outdated, :boolean, default: false
  end

  def validate(params) do
    %AwesomeElixir.Catalog.FilterParams{}
    |> cast(params, ~w(min_stars show_unstarred hide_outdated)a)
    |> validate_inclusion(:min_stars, ~w(all 10 50 100 500 1000))
  end
end
