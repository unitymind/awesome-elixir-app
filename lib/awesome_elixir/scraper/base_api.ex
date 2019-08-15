defmodule AwesomeElixir.Scraper.BaseApi do
  @moduledoc """
  Base module for building API-wrappers with expected JSON-responses.

  Define your base uri in `use` call such as:

      use AwesomeElixir.Scraper.BaseApi, "https://your.api.com/base/uri"

  Also trying decode response body using `Jason` in `c:HTTPoison.Base.process_response_body/1` implementation, which returns raw body in a case of decoding error.
  """

  defmacro __using__(base_uri) do
    quote do
      use HTTPoison.Base

      @impl true
      def process_request_url(url) do
        unquote(base_uri) <> url
      end

      @impl true
      def process_response_body(body) do
        case Jason.decode(body, keys: :atoms) do
          {:ok, decoded} -> decoded
          {:error, _} -> body
        end
      end
    end
  end
end
