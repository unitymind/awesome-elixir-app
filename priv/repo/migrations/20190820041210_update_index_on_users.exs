defmodule AwesomeElixir.Repo.Migrations.UpdateIndexOnUsers do
  use Ecto.Migration

  def change do
    drop index(:users, [:github_uid])
    create unique_index(:users, [:github_uid])
  end
end
