defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    update_index_spec =
      if Phoenix.Endpoint.Supervisor.server?(:awesome_elixir, AwesomeElixirWeb.Endpoint) do
        [
          Task.child_spec(fn ->
            Exq.enqueue(Exq, "default", AwesomeElixir.Workers.UpdateIndex, [])
          end)
        ]
      else
        []
      end

    children =
      [AwesomeElixir.Repo | Exq.Support.Mode.children([])] ++
        update_index_spec ++ [AwesomeElixirWeb.Endpoint]

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
end
