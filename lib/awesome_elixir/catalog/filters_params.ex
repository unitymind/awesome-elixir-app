defmodule AwesomeElixir.Catalog.FilterParams do
  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :min_stars, :string, default: "all"
    field :show_unstarred, :boolean, default: false
    field :hide_outdated, :boolean, default: false
    field :show_just_updated, :boolean, default: false
  end

  def validate(params) do
    %__MODULE__{}
    |> cast(params, ~w(min_stars show_unstarred hide_outdated show_just_updated)a)
    |> validate_inclusion(:min_stars, ~w(all 10 50 100 500 1000))
  end
end
