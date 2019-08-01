defmodule AwesomeElixir.Catalog.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @github_url_prefix "https://github.com/"
  @gitlab_url_prefix "https://gitlab.com/"

  schema "items" do
    belongs_to :category, AwesomeElixir.Catalog.Category

    field :description, :string
    field :name, :string
    field :stars_count, :integer
    field :updated_in, :integer
    field :url, :string
    field :github, :string
    field :gitlab, :string
    field :pushed_at, :utc_datetime
    field :is_dead, :boolean
    field :is_scrapped, :boolean

    timestamps()
  end

  @doc false
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
      :github,
      :gitlab,
      :category_id
    ])
    |> validate_required([:name, :url, :description])
    |> unique_constraint(:url)
    |> foreign_key_constraint(:category_id)
    |> assoc_constraint(:category)
    |> set_github()
    |> set_gitlab()
    |> set_updated_in()
  end

  defp set_github(changeset) do
    case changeset.changes do
      %{url: @github_url_prefix <> github} ->
        if String.split(github, "/", trim: true) |> length == 2 do
          changeset |> put_change(:github, String.replace(github, ~r/\/$|\.git$/, ""))
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp set_gitlab(changeset) do
    case changeset.changes do
      %{url: @gitlab_url_prefix <> gitlab} ->
        if String.split(gitlab, "/", trim: true) |> length == 2 do
          changeset |> put_change(:gitlab, String.replace(gitlab, ~r/\/$|\.git$/, ""))
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp set_updated_in(changeset) do
    case changeset.changes do
      %{pushed_at: pushed_at} ->
        changeset
        |> put_change(:updated_in, Date.diff(Date.utc_today(), DateTime.to_date(pushed_at)))

      _ ->
        changeset
    end
  end
end
