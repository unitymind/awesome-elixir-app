import Config

config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

# deploy_on_heroku = String.to_existing_atom(System.get_env("DEPLOY_ON_HEROKU") || "false")

if System.get_env("DEPLOY_ON_HEROKU") || "false" |> String.to_existing_atom(),
  do: import_config("prod.heroku.secret.exs")
