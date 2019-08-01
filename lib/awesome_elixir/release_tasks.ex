defmodule AwesomeElixir.ReleaseTasks do
  def migrate() do
    {:ok, _} = Application.ensure_all_started(:awesome_elixir)
    path = Application.app_dir(:awesome_elixir, "priv/repo/migrations")
    Ecto.Migrator.run(AwesomeElixir.Repo, path, :up, all: true)
  end
end
