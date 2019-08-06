defmodule AwesomeElixir.Catalog.Item do
  use TypedEctoSchema
  import Ecto.Changeset

  @github_url_prefix "https://github.com/"
  @gitlab_url_prefix "https://gitlab.com/"

  typed_schema "items" do
    belongs_to :category, AwesomeElixir.Catalog.Category

    field :description, :string
    field :name, :string
    field :stars_count, :integer
    field :updated_in, :integer
    field :url, :string

    embeds_one :git_source, GitSource, on_replace: :delete, primary_key: false do
      field :github, :string
      field :gitlab, :string
    end

    field :pushed_at, :utc_datetime
    field :is_dead, :boolean
    field :is_scrapped, :boolean

    timestamps()
  end

  @doc false
  @spec insert_or_update_changeset(AwesomeElixir.Catalog.Item.t(), map()) :: Ecto.Changeset.t()
  def insert_or_update_changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :url,
      :description,
      :stars_count,
      :pushed_at,
      :is_dead,
      :is_scrapped,
      :category_id
    ])
    |> cast_embed(:git_source, with: &git_source_changeset/2)
    |> validate_required([:name, :url, :description])
    |> unique_constraint(:url)
    |> foreign_key_constraint(:category_id)
    |> assoc_constraint(:category)
    |> set_git_source()
    |> set_updated_in()
  end

  defp git_source_changeset(schema, params) do
    schema
    |> cast(params, ~w(github gitlab)a)
  end

  defp set_git_source(%Ecto.Changeset{changes: %{url: @github_url_prefix <> rest}} = changeset) do
    handle_git_source(changeset, :github, rest)
  end

  defp set_git_source(%Ecto.Changeset{changes: %{url: @gitlab_url_prefix <> rest}} = changeset) do
    handle_git_source(changeset, :gitlab, rest)
  end

  defp set_git_source(changeset), do: changeset

  defp handle_git_source(changeset, kind, uri) do
    if String.split(uri, "/", trim: true) |> length == 2 do
      changeset
      |> put_embed(
        :git_source,
        %AwesomeElixir.Catalog.Item.GitSource{}
        |> Map.put(kind, String.replace(uri, ~r/\/$|\.git$/, ""))
      )
    else
      changeset
    end
  end

  defp set_updated_in(%Ecto.Changeset{changes: %{pushed_at: pushed_at}} = changeset) do
    changeset
    |> put_change(:updated_in, Date.diff(Date.utc_today(), DateTime.to_date(pushed_at)))
  end

  defp set_updated_in(changeset), do: changeset
end
