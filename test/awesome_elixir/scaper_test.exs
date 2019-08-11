defmodule AwesomeElixir.ScraperTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Catalog.{Category, Item}
  alias AwesomeElixir.Scraper

  describe "update_index()" do
    test "should be store parsed data to db and schedule AwesomeElixir.Jobs.UpdateItem jobs" do
      use_cassette "grab_awesome_elixir_markdown_readme" do
        assert {0, 0, 0} = {count_categories(), count_items(), count_jobs()}
        assert [:ok] = Scraper.update_index() |> Enum.uniq()
        assert {81, 1255, 1255} = {count_categories(), count_items(), count_jobs()}
      end
    end
  end

  defp count_categories, do: Repo.aggregate(Category, :count, :id)
  defp count_items, do: Repo.aggregate(Item, :count, :id)
  defp count_jobs, do: Repo.aggregate(from(j in "rihanna_jobs"), :count, :id)
end
