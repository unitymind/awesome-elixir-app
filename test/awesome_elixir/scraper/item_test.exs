defmodule AwesomeElixir.Scraper.ItemTest do
  use AwesomeElixir.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper.Item

  import AwesomeElixir.Support.Assertions

  @item_fields ~w(is_dead is_scrapped pushed_at stars_count updated_in)a

  setup do
    {:ok, %{id: category_id}} =
      build(:category)
      |> Catalog.insert_category()

    [item: build(:item, category_id: category_id)]
  end

  describe "update() with github.com url" do
    test "repo moved", %{item: item} do
      use_cassette "github_moved_repo" do
        item = create_item_with_url(item, "https://github.com/spawnproc/forms")

        assert {:ok, %Catalog.Item{is_dead: false, is_scrapped: true} = updated_item} =
                 Item.update(item)

        assert_not_equals_keys(item, updated_item, @item_fields ++ [:description])
      end
    end

    test "not found source", %{item: item} do
      use_cassette "github_missed_repo" do
        item = create_item_with_url(item, "https://github.com/missed/repo")

        assert {:ok, %Catalog.Item{is_dead: true, is_scrapped: true} = updated_item} =
                 Item.update(item)
      end
    end

    test "403 response", %{item: item} do
      use_cassette "github_403_response" do
        item = create_item_with_url(item, "https://github.com/elixir-lang/elixir")
        assert {:retry, %DateTime{}} = Item.update(item)
      end
    end

    test "other errors", %{item: item} do
      use_cassette "github_other_errors" do
        item = create_item_with_url(item, "https://github.com/elixir-lang/elixir")
        assert {:retry, :now} = Item.update(item)
      end
    end

    test "github not repo url trait as regular url", %{item: item} do
      use_cassette "github_not_repo_url" do
        item = create_item_with_url(item, "https://github.com/Driftrock/quiet_logger/pull/1")

        assert {:ok,
                %Catalog.Item{
                  is_dead: false,
                  is_scrapped: true,
                  git_source: nil,
                  pushed_at: nil,
                  stars_count: nil,
                  updated_in: nil
                } = updated_item} = Item.update(item)
      end
    end

    test "success", %{item: item} do
      use_cassette "github_elixir_lang" do
        item = create_item_with_url(item, "https://github.com/elixir-lang/elixir")

        assert {:ok,
                %Catalog.Item{
                  is_dead: false,
                  is_scrapped: true,
                  stars_count: 15713,
                  updated_in: updated_in,
                  pushed_at: pushed_at
                } = updated_item} = Item.update(item)

        assert_not_equals_keys(item, updated_item, @item_fields ++ [:description])
        assert updated_in > 0
        assert %DateTime{} = pushed_at
      end
    end
  end

  describe "update() with gitlab.com url" do
    test "not found source", %{item: item} do
      use_cassette "gitlab_missed_repo" do
        item = create_item_with_url(item, "https://gitlab.com/missed/repo")

        assert {:ok, %Catalog.Item{is_dead: true, is_scrapped: true} = updated_item} =
                 Item.update(item)
      end
    end

    test "repo with blank description not affect item description on update", %{item: item} do
      use_cassette "gitlab_olhado_rollex" do
        item = create_item_with_url(item, "https://gitlab.com/olhado/rollex")

        assert {:ok,
                %Catalog.Item{
                  is_dead: false,
                  is_scrapped: true,
                  stars_count: 0,
                  updated_in: updated_in,
                  pushed_at: pushed_at
                } = updated_item} = Item.update(item)

        assert_not_equals_keys(item, updated_item, @item_fields)
        assert item.description == updated_item.description
        assert updated_in > 0
        assert %DateTime{} = pushed_at
      end
    end

    test "other errors", %{item: item} do
      use_cassette "gitlab_other_errors" do
        item = create_item_with_url(item, "https://gitlab.com/runhyve/webapp")
        assert {:retry, %DateTime{}} = Item.update(item)
      end
    end

    test "success", %{item: item} do
      use_cassette "gitlab_runhyve_webapp" do
        item = create_item_with_url(item, "https://gitlab.com/runhyve/webapp")

        assert {:ok,
                %Catalog.Item{
                  is_dead: false,
                  is_scrapped: true,
                  stars_count: 2,
                  updated_in: updated_in,
                  pushed_at: pushed_at
                } = updated_item} = Item.update(item)

        assert_not_equals_keys(item, updated_item, @item_fields ++ [:description])
        assert updated_in > 0
        assert %DateTime{} = pushed_at
      end
    end
  end

  describe "update() with hex.pm url" do
    test "not exists hex.pm package", %{item: item} do
      use_cassette "hexpm_missed_package" do
        item = create_item_with_url(item, "https://hex.pm/packages/missed")

        refute item.git_source

        assert {:ok,
                %Catalog.Item{
                  git_source: nil,
                  is_dead: true,
                  is_scrapped: true
                } = updated_item} = Item.update(item)
      end
    end

    test "other errors on requesting hex.pm", %{item: item} do
      use_cassette "hexpm_other_errors" do
        item = create_item_with_url(item, "https://hex.pm/packages/ecto")
        assert {:retry, :now} = Item.update(item)
      end
    end

    test "with github url on hex.pm page", %{item: item} do
      use_cassette "hexpm_github_data_morph" do
        item = create_item_with_url(item, "https://hex.pm/packages/data_morph")

        refute item.git_source
        assert {:retry, :now} = Item.update(item)

        assert %Catalog.Item{
                 is_dead: false,
                 is_scrapped: false,
                 git_source: %Catalog.Item.GitSource{github: "robmckinnon/data_morph"}
               } = Catalog.get_item_by_id(item.id)
      end
    end

    test "with gitlab url on hex.pm page", %{item: item} do
      use_cassette "hexpm_gitlab_exsms" do
        item = create_item_with_url(item, "https://hex.pm/packages/exsms")

        refute item.git_source
        assert {:retry, :now} = Item.update(item)

        assert %Catalog.Item{
                 is_dead: false,
                 is_scrapped: false,
                 git_source: %Catalog.Item.GitSource{gitlab: "ahamtech/elixir/exsms"}
               } = Catalog.get_item_by_id(item.id)
      end
    end

    test "with absent git links on hex.pm page", %{item: item} do
      use_cassette "hexpm_without_git_links" do
        item = create_item_with_url(item, "https://hex.pm/packages/stream_weaver")

        refute item.git_source

        assert {:ok,
                %Catalog.Item{
                  git_source: nil,
                  is_dead: false,
                  is_scrapped: true
                } = updated_item} = Item.update(item)
      end
    end
  end

  describe "update() with regular url" do
    test "success", %{item: item} do
      use_cassette "nerves_project" do
        item = create_item_with_url(item, "http://nerves-project.org")

        refute item.git_source

        assert {:ok,
                %Catalog.Item{
                  git_source: nil,
                  is_dead: false,
                  is_scrapped: true,
                  stars_count: nil,
                  updated_in: nil,
                  pushed_at: nil
                } = updated_item} = Item.update(item)
      end
    end

    test "not found", %{item: item} do
      use_cassette "missed_nerves_project" do
        item = create_item_with_url(item, "http://nerves-project.org/missed")

        refute item.git_source

        assert {:ok,
                %Catalog.Item{
                  git_source: nil,
                  is_dead: true,
                  is_scrapped: true,
                  stars_count: nil,
                  updated_in: nil,
                  pushed_at: nil
                } = updated_item} = Item.update(item)
      end
    end

    test "not exists domain", %{item: item} do
      use_cassette "not_exists_missed" do
        item = create_item_with_url(item, "http://notexistmissed.com")

        refute item.git_source

        assert {:ok,
                %Catalog.Item{
                  git_source: nil,
                  is_dead: true,
                  is_scrapped: true,
                  stars_count: nil,
                  updated_in: nil,
                  pushed_at: nil
                } = updated_item} = Item.update(item)
      end
    end
  end

  defp create_item_with_url(item, url) do
    assert {:ok, item} =
             %{item | url: url}
             |> Catalog.insert_item()

    item
  end
end
