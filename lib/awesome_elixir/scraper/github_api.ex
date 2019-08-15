defmodule AwesomeElixir.Scraper.GithubApi do
  @moduledoc """
  GitHub specific API-wrapper.

    * Base uri: `https://api.github.com`
  """

  use AwesomeElixir.Scraper.BaseApi, "https://api.github.com"

  @doc """
  Set username and GitHub personal token from `Config` as `HTTPoison` options for  `:hackney basic_auth`.
  """
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

  @doc """
  Make [`GET /repos/:owner/:repo`](https://developer.github.com/v3/repos/#get) API-call there is given `uri` match `:owner/:repo` format.
  """
  @spec get_repo(String.t()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  def get_repo(uri), do: get("/repos/" <> uri)
end
