defmodule AwesomeElixir.Scraper.HexpmApi do
  use AwesomeElixir.Scraper.BaseApi, "https://hex.pm/api"

  def get_package(uri), do: get("/packages/#{uri}")
end
