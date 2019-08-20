defmodule AwesomeElixir.ReleaseTasks do
  @moduledoc """
  Tasks for executing due release phase of deployment.
  """
  @app :awesome_elixir

  @doc """
  Migrate all pending migration.

      $ bin/awesome_elixir eval "AwesomeElixir.ReleaseTasks.migrate()"
  """
  # coveralls-ignore-start
  @spec migrate() :: any()
  def migrate do
    load_app()

    for repo <- repos() do
      with {:ok, _, _} <- Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true)),
           do: :ok
    end
  end

  @doc false
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  # coveralls-ignore-stop
end
