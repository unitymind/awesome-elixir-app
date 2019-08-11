defmodule AwesomeElixir.ScraperTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Catalog.{Category, Item}
  alias AwesomeElixir.Scraper

  describe "update_index()" do
    test "should be store parsed data to db and schedule AwesomeElixir.Jobs.UpdateItem jobs" do
      use_cassette "grab_awesome_elixir_markdown_readme" do
        assert 0 == Repo.aggregate(Category, :count, :id)
        assert 0 == Repo.aggregate(Item, :count, :id)
        assert 0 == Repo.aggregate(from(j in "rihanna_jobs"), :count, :id)

        Scraper.update_index()

        assert 81 == Repo.aggregate(Category, :count, :id)
        assert 1255 == Repo.aggregate(Item, :count, :id)
        assert 1255 == Repo.aggregate(from(j in "rihanna_jobs"), :count, :id)
      end
    end
  end
end
