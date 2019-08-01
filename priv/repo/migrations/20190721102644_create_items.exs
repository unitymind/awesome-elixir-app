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
      add :category_id, references(:categories, on_delete: :restrict, on_update: :update_all)

      timestamps()
    end

    create index(:items, [:category_id])
    create unique_index(:items, [:url])
    create index(:items, [:stars_count])
    create index(:items, [:updated_in])
    create index(:items, [:is_dead])
  end
end
