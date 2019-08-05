defmodule AwesomeElixir.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false

      timestamps()
    end

    create unique_index(:categories, [:slug])
    create index(:categories, [:name])
  end
end
