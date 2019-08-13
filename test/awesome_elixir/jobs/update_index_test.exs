defmodule AwesomeElixir.Jobs.UpdateIndexTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Jobs

  test "should be store parsed data to db and schedule AwesomeElixir.Jobs.UpdateItem jobs" do
    use_cassette "grab_awesome_elixir_markdown_readme" do
      assert {0, 0, 0} = {count_categories(), count_items(), count_jobs()}
      assert :ok = Jobs.UpdateIndex.perform([])
      assert {81, 1255, 1256} = {count_categories(), count_items(), count_jobs()}
    end
  end

  test "should prevent description update on scraped item" do
    use_cassette "grab_awesome_elixir_markdown_readme" do
      assert :ok = Jobs.UpdateIndex.perform([])

      query =
        from Catalog.Item,
          order_by: fragment("RANDOM()"),
          limit: 1

      assert %Catalog.Item{} = item = Repo.one(query)
      updated_description = Faker.Lorem.sentence()

      assert {:ok, updated_item} =
               Catalog.update_item(item, %{
                 description: updated_description,
                 is_dead: false,
                 is_scrapped: true
               })

      assert item.description != updated_item.description
      assert :ok = Jobs.UpdateIndex.perform([])
      assert %Catalog.Item{description: ^updated_description} = Catalog.get_item_by_id(item.id)
    end
  end

  #  describe "update_item/1" do
  #    setup do
  #      {:ok, %{id: category_id}} =
  #        build(:category)
  #        |> Catalog.insert_category()
  #
  #      [item: build(:item, category_id: category_id)]
  #    end
  #
  #    test "success", %{item: item} do
  #      use_cassette "github_elixir_lang" do
  #        item = create_item_with_url(item, "https://github.com/elixir-lang/elixir")
  #        assert {:ok, %Catalog.Item{} = updated_item} = Scraper.update_item(item.id)
  #      end
  #    end
  #  end

  defp count_categories, do: Repo.aggregate(Catalog.Category, :count, :id)
  defp count_items, do: Repo.aggregate(Catalog.Item, :count, :id)
end
