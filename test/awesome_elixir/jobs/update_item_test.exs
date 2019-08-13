defmodule AwesomeElixir.Jobs.UpdateItemTest do
  use AwesomeElixir.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Jobs

  setup do
    use_cassette "grab_awesome_elixir_markdown_readme" do
      Jobs.UpdateIndex.perform([])
    end
  end

  test "success item update with github url" do
    use_cassette "github_phoenix_framework" do
      url = "https://github.com/phoenixframework/phoenix"

      assert %Catalog.Item{
               is_dead: false,
               is_scrapped: false,
               stars_count: nil,
               updated_in: nil,
               pushed_at: nil
             } = item = AwesomeElixir.Catalog.get_item_by_url(url)

      Jobs.UpdateItem.perform([item.id])

      assert %Catalog.Item{
               is_dead: false,
               is_scrapped: true,
               stars_count: stars_count,
               updated_in: updated_in,
               pushed_at: %DateTime{} = _pushed_at
             } = AwesomeElixir.Catalog.get_item_by_url(url)

      assert is_integer(stars_count)
      assert is_integer(updated_in)
    end
  end

  test "set git_source github on item update with hex.pm url" do
    use_cassette "hexpm_github_data_morph" do
      url = "https://hex.pm/packages/data_morph"

      assert %Catalog.Item{
               git_source: %Catalog.Item.GitSource{},
               is_dead: false,
               is_scrapped: false,
               stars_count: nil,
               updated_in: nil,
               pushed_at: nil
             } = item = AwesomeElixir.Catalog.get_item_by_url(url)

      Jobs.UpdateItem.perform([item.id])

      assert %Catalog.Item{
               git_source: %Catalog.Item.GitSource{github: "robmckinnon/data_morph"},
               is_dead: false,
               is_scrapped: false,
               stars_count: nil,
               updated_in: nil,
               pushed_at: nil
             } = AwesomeElixir.Catalog.get_item_by_url(url)
    end
  end

  test "item update with github url with 403 response" do
    use_cassette "github_phoenix_framework_403_response" do
      url = "https://github.com/phoenixframework/phoenix"

      assert %Catalog.Item{
               is_dead: false,
               is_scrapped: false,
               stars_count: nil,
               updated_in: nil,
               pushed_at: nil
             } = item = AwesomeElixir.Catalog.get_item_by_url(url)

      Jobs.UpdateItem.perform([item.id])

      assert %Catalog.Item{
               is_dead: false,
               is_scrapped: false,
               stars_count: nil,
               updated_in: nil,
               pushed_at: nil
             } = AwesomeElixir.Catalog.get_item_by_url(url)
    end
  end
end
