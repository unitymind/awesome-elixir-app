defmodule AwesomeElixir.Repo.Migrations.CreateGithubTokenIndexOnUser do
  use Ecto.Migration

  def change do
    create index(:users, [:github_token])
  end
end
