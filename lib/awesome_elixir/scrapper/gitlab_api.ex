defmodule AwesomeElixir.Scrapper.GitlabApi do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://gitlab.com/api/v4" <> url
  end

  def process_response_body(body) do
    body
    |> Jason.decode!(%{keys: :atoms})
  end

  def process_request_options(options) do
    options |> Keyword.put(:follow_redirect, true)
  end
end
