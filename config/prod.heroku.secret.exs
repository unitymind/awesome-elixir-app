import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :awesome_elixir, AwesomeElixir.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "16")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

port = String.to_integer(System.get_env("PORT") || "4000")
host = System.get_env("HOST") || "localhost"
run_server = String.to_existing_atom(System.get_env("RUN_SERVER") || "true")

config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  http: [:inet6, port: port, compress: true],
  url: [scheme: "https", host: host, port: port],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: secret_key_base,
  server: run_server

github_username =
  System.get_env("GITHUB_USERNAME") ||
    raise """
    environment variable GITHUB_USERNAME is missing.
    """

github_token =
  System.get_env("GITHUB_TOKEN") ||
    raise """
    environment variable GITHUB_TOKEN is missing.
    """

config :awesome_elixir, AwesomeElixirWeb.GithubApi,
  username: github_username,
  token: github_token
