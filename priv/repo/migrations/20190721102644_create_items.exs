defmodule AwesomeElixir.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :url, :string
      add :github, :string
      add :gitlab, :string
      add :description, :text
      add :stars_count, :integer
      add :updated_in, :integer
      add :pushed_at, :utc_datetime
      add :is_dead, :boolean, default: false
      add :is_scrapped, :boolean, default: false
      add :category_id, references(:categories, on_delete: :restrict, on_update: :update_all)

      timestamps()
    end

    create index(:items, [:category_id])
    create index(:items, [:name])
    create unique_index(:items, [:url])
    create index(:items, [:is_scrapped, :is_dead, :stars_count, :updated_in], name: :items_full_filters_index)
    create index(:items, [:is_scrapped, :is_dead, :updated_in], name: :items_filters_without_stars_count_index)
  end
end
