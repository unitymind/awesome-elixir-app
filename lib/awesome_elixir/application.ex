defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      AwesomeElixir.Repo,
      # Start the endpoint when the application starts
      AwesomeElixirWeb.Endpoint,
      # Starts a worker by calling: AwesomeElixir.Worker.start_link(arg)
      # {AwesomeElixir.Worker, arg},
      %{
        id: Exq,
        start: {Exq, :start_link, []}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeElixir.Supervisor]
    start_result = Supervisor.start_link(children, opts)
    Exq.enqueue_in(Exq, "default", 5, AwesomeElixir.Workers.UpdateIndex, [])
    start_result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
