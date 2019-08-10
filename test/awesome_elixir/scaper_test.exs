defmodule AwesomeElixir.ScraperTest do
  use AwesomeElixir.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

#  alias AwesomeElixir.Catalog.{Category, Item}
  alias AwesomeElixir.Scraper

  describe "update_index()" do
    setup do
      HTTPoison.start()
      :ok
    end
#    test "should be store parsed data to db" do
#      use_cassette "grab_awesome_elixir_markdown_readme" do
#        Scraper.update_index()
#      end
#    end
  end
end