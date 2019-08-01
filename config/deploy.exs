import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :awesome_elixir, AwesomeElixir.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20")
