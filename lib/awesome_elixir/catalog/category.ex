defmodule AwesomeElixir.Catalog.Category do
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    timestamps()

    has_many :items, AwesomeElixir.Catalog.Item
  end

  @doc false
  @spec insert_or_update_changeset(AwesomeElixir.Catalog.Category.t(), map()) ::
          Ecto.Changeset.t()
  def insert_or_update_changeset(category, attrs) do
    category
    |> cast(attrs, ~w(name slug description)a)
    |> validate_required(~w(name slug description)a)
  end
end
