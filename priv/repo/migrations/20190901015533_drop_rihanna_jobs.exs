defmodule AwesomeElixir.Repo.Migrations.DropRihannaJobs do
  use Ecto.Migration

  def change do
    drop table(:rihanna_jobs)
  end
end
