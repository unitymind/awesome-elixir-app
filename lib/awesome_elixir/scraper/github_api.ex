defmodule AwesomeElixir.Scraper.GithubApi do
  use AwesomeElixir.Scraper.BaseApi, "https://api.github.com"

  @impl true
  def process_request_options(options) do
    with {:ok, github_api_config} <-
           Application.fetch_env(:awesome_elixir, AwesomeElixirWeb.GithubApi),
         # coveralls-ignore-start
         %{username: username, token: token} <- Enum.into(github_api_config, %{}) do
      options
      |> Keyword.put(:hackney, basic_auth: {username, token})

      # coveralls-ignore-stop
    else
      _ -> options
    end
  end

  def get_repo(uri), do: get("/repos/" <> uri)
end
