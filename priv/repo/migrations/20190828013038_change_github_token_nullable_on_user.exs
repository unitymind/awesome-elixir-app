defmodule AwesomeElixir.Repo.Migrations.ChangeGithubTokenNullableOnUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      modify :github_token, :string, null: true
    end
  end
end
