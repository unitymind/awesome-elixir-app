defmodule AwesomeElixir.Scraper.GithubApi do
  @moduledoc """
  GitHub specific API-wrapper.

    * Base uri: `https://api.github.com`
  """

  alias AwesomeElixir.Accounts.RandomGithubTokenAgent
  use AwesomeElixir.Scraper.BaseApi, "https://api.github.com"

  @doc """
  Set username and random GitHub personal token from `AwesomeElixir.Catalog.User` as `HTTPoison` options for  `:hackney basic_auth`.
  """
  @impl true
  def process_request_options(options) do
    options = super(options)

    case RandomGithubTokenAgent.get() do
      nil ->
        options

      token ->
        Keyword.get_and_update(options, :hackney, fn hackney_options ->
          {hackney_options, Keyword.put(hackney_options, :basic_auth, {"awesome_elixir", token})}
        end)
        |> elem(1)
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
