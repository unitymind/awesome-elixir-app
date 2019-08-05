defmodule AwesomeElixir.Scrapper.GithubApi do
  use AwesomeElixir.Scrapper.BaseApi, "https://api.github.com"

  @impl true
  def process_request_options(options) do
    case Application.fetch_env(:awesome_elixir, AwesomeElixirWeb.GithubApi) do
      {:ok, github_api_config} ->
        case Enum.into(github_api_config, %{}) do
          %{username: username, token: token} ->
            options
            |> Keyword.put(:hackney, basic_auth: {username, token})

          _ ->
            options
        end

      :error ->
        options
    end
  end
end
