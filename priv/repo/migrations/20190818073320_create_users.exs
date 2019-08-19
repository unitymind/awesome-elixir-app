defmodule AwesomeElixir.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :github_uid, :id, null: false
      add :github_token, :string, null: false
      add :profile, :map, default: %{}, null: false

      timestamps()
    end

    create index(:users, [:github_uid])
  end
end
