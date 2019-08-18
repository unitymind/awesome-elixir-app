# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :awesome_elixir,
  ecto_repos: [AwesomeElixir.Repo]

# Configures the endpoint
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B6vJcLfnjG9qdzSD5YgEmZG2Uri0YRUVh+2AnXq+XFgy2vaqngLRuF8YiLR3VpBA",
  render_errors: [view: AwesomeElixirWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwesomeElixir.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Rihanna Producer and Dispatcher
config :rihanna,
  producer_postgres_connection: {Ecto, AwesomeElixir.Repo},
  behaviour_only: true,
  dispatcher_max_concurrency: 10,
  dispatcher_poll_interval: :timer.seconds(1)

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
