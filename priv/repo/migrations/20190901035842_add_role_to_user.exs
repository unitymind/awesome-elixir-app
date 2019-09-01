defmodule AwesomeElixir.Repo.Migrations.AddRoleToUser do
  alias AwesomeElixir.EctoEnums.Accounts
  use Ecto.Migration

  def change do
    Accounts.UserRole.create_type()

    alter table(:users) do
      add :role, Accounts.UserRole.type(), default: "regular", null: false
    end
  end
end
