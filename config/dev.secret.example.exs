import Config

config :awesome_elixir, AwesomeElixirWeb.GithubApi,
  # GitHub accept any username
  username: "awesome_elixir",
  # Replace with generated GitHub Personal Access Token
  token: "GITHUB_TOKEN"

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  # Replace with your GitHub app Client ID
  client_id: "GITHUB_CLIENT_ID",
  # Replace with your GitHub app Client secret
  client_secret: "GITHUB_CLIENT_SECRET"

config :awesome_elixir, AwesomeElixirWeb.Guardian,
  issuer: "awesome_elixir_app",
  # Replace it. You can use `mix guardian.gen.secret` to get one
  secret_key: "GUARDIAN_SECRET_KEY"
