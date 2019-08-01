defmodule AwesomeElixir.Scrapper.HexpmApi do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://hex.pm/api" <> url
  end

  def process_response_body(body) do
    body
    |> Jason.decode!(%{keys: :atoms})
  end
end
