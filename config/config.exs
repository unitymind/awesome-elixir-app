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

config :exq,
  start_on_application: false,
  concurrency: 10,
  scheduler_enable: true,
  max_retries: 25

config :exq_ui,
  server: false

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

config :awesome_elixir, AwesomeElixirWeb.Guardian.CommonPipeline,
  module: AwesomeElixirWeb.Guardian,
  error_handler: AwesomeElixirWeb.Guardian.AuthErrorHandler

config :awesome_elixir, AwesomeElixirWeb.Guardian.AuthenticatedPipeline,
  module: AwesomeElixirWeb.Guardian,
  error_handler: AwesomeElixirWeb.Guardian.AuthErrorHandler

config :awesome_elixir, AwesomeElixirWeb.Guardian.NotAuthenticatedPipeline,
  module: AwesomeElixirWeb.Guardian,
  error_handler: AwesomeElixirWeb.Guardian.AuthErrorHandler

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
