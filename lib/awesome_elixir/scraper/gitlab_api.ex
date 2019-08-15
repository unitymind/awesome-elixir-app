defmodule AwesomeElixir.Scraper.GitlabApi do
  @moduledoc """
  GitLab specific API-wrapper.

    * Base uri: `https://gitlab.com/api/v4`
  """

  use AwesomeElixir.Scraper.BaseApi, "https://gitlab.com/api/v4"

  @doc """
  Put `:follow_redirect` option.
  """
  @impl true
  def process_request_options(options) do
    options |> Keyword.put(:follow_redirect, true)
  end

  @doc """
  Make [`GET /projects/:id`](https://docs.gitlab.com/ee/api/projects.html#get-single-project) API-call there is given `uri` match the uri path of the project.
  """
  @spec get_project(String.t()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  def get_project(uri), do: get("/projects/" <> URI.encode_www_form(uri))
end
