defmodule AwesomeElixir.Catalog.FilterParams do
  @moduledoc """
  Describes embedded schema using `TypedEctoSchema` for cast and validation incoming params.

      field :min_stars, :string, default: "all"
      field :show_unstarred, :boolean, default: false
      field :hide_outdated, :boolean, default: false
      field :show_just_updated, :boolean, default: false
  """

  use TypedEctoSchema
  import Ecto.Changeset
  use Memoize

  @primary_key false

  typed_embedded_schema do
    field :min_stars, :string, default: "all"
    field :show_unstarred, :boolean, default: false
    field :hide_outdated, :boolean, default: false
    field :show_just_updated, :boolean, default: false
  end

  @fields ~w(min_stars show_unstarred hide_outdated show_just_updated)a
  @allowed_min_stars_values ~w(all 10 50 100 500 1000)

  @doc """
    Cast and validate incoming params according to field's types.

    * Allowed: `min_stars`, `show_unstarred`, `hide_outdated` and `show_just_updated`
    * Validate inclusion of `min_stars` in list ```["all", "10", "50", "100", "500", "1000"]```
  """
  @spec validate(map()) :: Ecto.Changeset.t()
  def validate(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_inclusion(:min_stars, @allowed_min_stars_values)
  end

  @doc """
  Make call `validate/1` and produce default values for invalid fields.
  """
  @spec execute(map()) :: __MODULE__.t()
  def execute(params)

  defmemo execute(params) do
    case validate(params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        Ecto.Changeset.apply_changes(changeset)

      %Ecto.Changeset{} = changeset ->
        changeset.data |> Map.merge(Map.drop(changeset.changes, Keyword.keys(changeset.errors)))
    end
  end
end
