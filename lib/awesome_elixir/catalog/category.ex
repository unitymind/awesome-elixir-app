defmodule AwesomeElixir.Catalog.Category do
  @moduledoc """
  Describes `Category` entity using `TypedEctoSchema`.

      field :name, :string
      field :slug, :string
      field :description, :string
      timestamps()

      has_many :items, AwesomeElixir.Catalog.Item
  """

  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    timestamps()

    has_many :items, AwesomeElixir.Catalog.Item
  end

  @doc """
  Cast and validate data for insert.

    * Allowed and required: `name`, `slug` and `description`
    * Unique constraint: `slug`
  """
  @spec insert_changeset(map()) :: Ecto.Changeset.t()
  def insert_changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, ~w(name slug description)a)
    |> validate_required(~w(name slug description)a)
    |> unique_constraint(:slug)
  end

  @doc """
  Cast and validate data for update.

    * Allowed and required: `name` and `description`
  """
  @spec update_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = category, %{} = attrs) do
    category
    |> cast(attrs, ~w(name description)a)
    |> validate_required(~w(name description)a)
  end
end
