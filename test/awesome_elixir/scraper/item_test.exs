defmodule AwesomeElixir.Scraper.ItemTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Scraper.Item

  setup do
    {:ok, category} =
      build(:category)
      |> Catalog.insert_category()

    [category: category]
  end

  #  setup_all do
  #    HTTPoison.start()
  #  end
  #
  #  describe "update()" do
  #    test "success download and parse awesome elixir markdown readme" do
  #      use_cassette "grab_awesome_elixir_markdown_readme" do
  #        categories = Index.update()
  #
  #        assert 81 == length(categories)
  #
  #        for category <- categories do
  #          assert %Index.Category{name: name, slug: slug, description: description, items: items} =
  #                   category
  #
  #          [name, slug, description] |> assert_is_binary_list()
  #
  #          for item <- items do
  #            assert %Index.Item{name: name, url: url, description: description} = item
  #            [name, url, description] |> assert_is_binary_list()
  #          end
  #        end
  #
  #        assert 1255 ==
  #                 Enum.reduce(categories, 0, fn %{items: items}, acc -> acc + length(items) end)
  #      end
  #    end
  #  end
  #
  #  defp assert_is_binary_list(list) when is_list(list) do
  #    for field <- list, do: assert(is_binary(field))
  #  end
end
