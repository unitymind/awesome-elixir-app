defmodule AwesomeElixir.Scraper.CommonHttp do
  use HTTPoison.Base

  @doc """
  Put `hackney: [pool: :default]`.
  """
  @impl true
  def process_request_options(options) do
    options
    |> Keyword.put(:hackney, pool: :default)
  end
end
