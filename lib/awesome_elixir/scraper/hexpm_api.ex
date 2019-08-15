defmodule AwesomeElixir.Scraper.HexpmApi do
  @moduledoc """
  Hex.pm specific API-wrapper.

    * Base uri: `https://hex.pm/api`
  """
  use AwesomeElixir.Scraper.BaseApi, "https://hex.pm/api"

  @doc """
  Make `GET /packages/:name` API-call there is given `uri` match Hex.pm package name.
  """
  @spec get_package(String.t()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  def get_package(uri), do: get("/packages/#{uri}")
end
