defmodule AwesomeElixir.Catalog.Item do
  @moduledoc """
  Describes `Item` entity using `TypedEctoSchema`.

      belongs_to :category, AwesomeElixir.Catalog.Category

      field :name, :string
      field :description, :string
      field :stars_count, :integer
      field :updated_in, :integer
      field :url, EctoFields.URL

      embeds_one :git_source, GitSource, on_replace: :delete, primary_key: false do
        field :github, :string
        field :gitlab, :string
      end

      field :pushed_at, :utc_datetime
      field :is_dead, :boolean
      field :is_scrapped, :boolean

      timestamps()
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @github_url_prefix "https://github.com/"
  @gitlab_url_prefix "https://gitlab.com/"

  typed_schema "items" do
    belongs_to :category, AwesomeElixir.Catalog.Category

    field :name, :string
    field :description, :string
    field :stars_count, :integer
    field :updated_in, :integer
    field :url, EctoFields.URL

    embeds_one :git_source, GitSource, on_replace: :delete, primary_key: false do
      @moduledoc """
      Embedded schema, holding git source data.

          field :github, :string
          field :gitlab, :string
      """

      field :github, :string
      field :gitlab, :string
    end

    field :pushed_at, :utc_datetime
    field :is_dead, :boolean
    field :is_scrapped, :boolean

    timestamps()
  end

  @allowed_git_sources ~w(github gitlab)a
  @insert_fields ~w(category_id name url description)a
  @update_required_fields ~w(category_id name description)a
  @update_optional_fields ~w(stars_count pushed_at is_dead is_scrapped)a

  @doc """
  Cast and validate data for insert.

    * Allowed and required: `category_id`, `name`, `url` and `description`
    * Unique constraint: `url`
    * Assoc constraint: `category`

  Also set `git_source` derived from `url` if applicable.
  """
  @spec insert_changeset(map()) :: Ecto.Changeset.t()
  def insert_changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, @insert_fields)
    |> validate_required(@insert_fields)
    |> unique_constraint(:url)
    |> assoc_constraint(:category)
    |> set_git_source()
  end

  @doc """
    Cast and validate data for update.

    * Allowed: `category_id`, `name`, `description`, `stars_count`, `pushed_at`, `is_dead`, `is_scrapped` and `git_source`
    * Cast `git_source` on embedded schema
    * Required: `category_id`, `name`, `description`
    * Assoc constraint: `category`
    * Validate that `stars_count` is greater than or equal to 0
  """
  @spec update_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = item, %{} = attrs) do
    item
    |> cast(attrs, @update_required_fields ++ @update_optional_fields)
    |> validate_required(@update_required_fields)
    |> cast_embed(:git_source, with: &git_source_changeset/2)
    |> assoc_constraint(:category)
    |> validate_number(:stars_count, greater_than_or_equal_to: 0)
    |> set_updated_in()
  end

  defp git_source_changeset(schema, params) do
    schema
    |> cast(params, @allowed_git_sources)
  end

  defp set_git_source(%Ecto.Changeset{changes: %{url: @github_url_prefix <> uri}} = changeset) do
    handle_git_source(changeset, :github, uri)
  end

  defp set_git_source(%Ecto.Changeset{changes: %{url: @gitlab_url_prefix <> uri}} = changeset) do
    handle_git_source(changeset, :gitlab, uri)
  end

  defp set_git_source(changeset), do: changeset

  defp handle_git_source(changeset, kind, uri) when is_binary(uri),
    do:
      handle_git_source(
        changeset,
        kind,
        uri |> String.replace(~r/\.git$/, "") |> String.split("/", trim: true)
      )

  defp handle_git_source(changeset, :github, uri) when is_list(uri) and length(uri) != 2,
    do: changeset

  defp handle_git_source(changeset, kind, uri) when is_list(uri) do
    uri = uri |> Enum.join("/")

    changeset
    |> put_embed(
      :git_source,
      %__MODULE__.GitSource{}
      |> Map.put(kind, uri)
    )
  end

  defp set_updated_in(%Ecto.Changeset{changes: %{pushed_at: pushed_at}} = changeset)
       when not is_nil(pushed_at) do
    changeset
    |> put_change(:updated_in, Date.diff(Date.utc_today(), DateTime.to_date(pushed_at)))
  end

  defp set_updated_in(changeset), do: changeset
end
