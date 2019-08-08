defmodule AwesomeElixir.Scrapper.GithubApiTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias AwesomeElixir.Scrapper.GithubApi
  alias HTTPoison.Response

  setup_all do
    HTTPoison.start()
  end

  test "success /repos/elixir-lang/elixir" do
    use_cassette "httpoison_get_github_repos_elixir_lang" do
      {:ok, %Response{status_code: status_code, body: body}} =
        GithubApi.get("/repos/elixir-lang/elixir")

      assert status_code == 200
    end
  end
end
