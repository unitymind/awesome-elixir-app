defmodule AwesomeElixir.Scraper.GitlabApi do
  use AwesomeElixir.Scraper.BaseApi, "https://gitlab.com/api/v4"

  @impl true
  def process_request_options(options) do
    options |> Keyword.put(:follow_redirect, true)
  end
end
