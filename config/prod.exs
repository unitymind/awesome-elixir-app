import Config

config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

deploy_on_heroku = String.to_existing_atom(System.get_env("DEPLOY_ON_HEROKU") || "false")

if deploy_on_heroku, do: import_config "prod.secret.exs"
