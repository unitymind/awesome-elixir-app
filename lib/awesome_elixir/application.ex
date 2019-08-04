defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    {migration_spec, update_index_spec} =
      if Phoenix.Endpoint.server?(:awesome_elixir, AwesomeElixirWeb.Endpoint) do
        {migration_task_spec(), update_index_task_spec(5)}
      else
        {nil, nil}
      end

    children =
      ([AwesomeElixir.Repo, migration_spec | Exq.Support.Mode.children([])] ++
         [update_index_spec, AwesomeElixirWeb.Endpoint])
      |> Enum.reject(&is_nil/1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp migration_task_spec do
    Supervisor.child_spec(
      {Task,
        fn ->
          AwesomeElixir.ReleaseTasks.migrate()
        end},
      id: {Task, 1}
    )
  end

  defp update_index_task_spec(delay) do
    Supervisor.child_spec(
      {Task,
        fn ->
          Exq.enqueue_in(Exq, "default", delay, AwesomeElixir.Workers.UpdateIndex, [])
        end},
      id: {Task, 2}
    )
  end
end
