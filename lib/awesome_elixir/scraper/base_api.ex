defmodule AwesomeElixir.Scraper.BaseApi do
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
          {:error, _} -> %{}
        end
      end
    end
  end
end
