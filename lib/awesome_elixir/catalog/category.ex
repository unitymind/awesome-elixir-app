defmodule AwesomeElixir.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    has_many :items, AwesomeElixir.Catalog.Item

    field :description, :string
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def insert_or_update_changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug])
  end
end
