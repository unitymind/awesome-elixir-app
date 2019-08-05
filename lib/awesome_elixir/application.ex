defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      AwesomeElixir.Repo,
      AwesomeElixir.Application.SupervisorWithBlockedMigration
    ]

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

  defmodule SupervisorWithBlockedMigration do
    use Supervisor

    def start_link(init_arg) do
      Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    @impl true
    def init(_init_arg) do
      update_index_spec =
        if Phoenix.Endpoint.server?(:awesome_elixir, AwesomeElixirWeb.Endpoint) do
          AwesomeElixir.ReleaseTasks.migrate()

          Supervisor.child_spec(
            {Task,
             fn ->
               Exq.enqueue_in(Exq, "default", 5, AwesomeElixir.Workers.UpdateIndex, [])
             end},
            id: {Task, :update_index}
          )
        end

      children =
        (Exq.Support.Mode.children([]) ++ [update_index_spec, AwesomeElixirWeb.Endpoint])
        |> Enum.reject(&is_nil/1)

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end
