defmodule AwesomeElixir.Scraper.IndexTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Scraper.Index

  test "Should raise NotFetchedError on HTTP-error" do
    use_cassette "awesome_elixir_markdown_readme_not_found" do
      assert_raise Index.NotFetchedError, "404: Not Found", fn ->
        Index.update()
      end
    end
  end

  test "Should raise HTTPoison.Error on network issues" do
    use_cassette "awesome_elixir_markdown_readme_httpoison_error" do
      assert_raise HTTPoison.Error, fn -> Index.update() end
    end
  end
end
