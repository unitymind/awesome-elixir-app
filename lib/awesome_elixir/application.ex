defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias AwesomeElixir.Jobs

  def start(_type, _args) do
    children = [
      AwesomeElixir.Repo,
      __MODULE__.ServerModeSupervisor,
      {AwesomeElixir.Accounts.RandomGithubTokenAgent,
       String.to_integer(System.get_env("GITHUB_TOKEN_USAGE_THRESHOLD") || "50")}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  # coveralls-ignore-start
  def config_change(changed, _new, removed) do
    AwesomeElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # coveralls-ignore-stop

  defmodule ServerModeSupervisor do
    @moduledoc false
    use Supervisor

    def start_link(init_arg) do
      Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end

    @impl true
    def init(_init_arg) do
      server_mode_specs =
        if Phoenix.Endpoint.server?(:awesome_elixir, AwesomeElixirWeb.Endpoint) do
          # coveralls-ignore-start

          Exq.Support.Mode.children([]) ++
            [
              Supervisor.child_spec(
                {Task, fn -> Jobs.schedule_update_in(5) end},
                id: {Task, :update_index}
              )
            ]

          # coveralls-ignore-stop
        else
          []
        end

      children = server_mode_specs ++ [AwesomeElixirWeb.Endpoint]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end
