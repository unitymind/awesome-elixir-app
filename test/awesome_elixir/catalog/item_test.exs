defmodule AwesomeElixir.Catalog.ItemTest do
  use AwesomeElixir.DataCase, async: true
  alias AwesomeElixir.Catalog

  import AwesomeElixir.Support.Assertions
  import AwesomeElixir.Support.Helpers

  setup do
    {:ok, category} =
      build(:category)
      |> Catalog.insert_category()

    item = build(:item, category_id: category.id)

    [item: item]
  end

  describe "insert_changeset() validations" do
    test "not inserted with blank: name, url, description", %{item: item} do
      assert_insert_cant_be_blank(item, ~w(name url description)a, &Catalog.insert_item/1)
    end

    test "not inserted with nil category_id", %{item: item} do
      assert {:error, changeset} = %{item | category_id: nil} |> Catalog.insert_item()
      assert %{category_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "not inserted with not exists category_id", %{item: item} do
      assert {:error, changeset} = %{item | category_id: 0} |> Catalog.insert_item()
      assert %{category: ["does not exist"]} = errors_on(changeset)
    end

    test "not inserted with invalid url", %{item: item} do
      assert {:error, changeset} =
               %{item | url: "http://example.com\\blog\\first"}
               |> Catalog.insert_item()

      assert %{url: ["is invalid"]} = errors_on(changeset)
    end

    test "not inserted with duplicate url", %{item: item} do
      assert {:ok, _} = Catalog.insert_item(item)
      assert {:error, changeset} = Catalog.insert_item(item)
      assert %{url: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "set_git_source() within insert_changeset()" do
    test "set git_source for github url", %{item: item} do
      assert {:ok, item} =
               %{item | url: "https://github.com/github_user/repo"}
               |> Catalog.insert_item()

      assert %{git_source: %{github: "github_user/repo"}} = item
    end

    test "bypass set git_source for github url if missed format", %{item: item} do
      assert {:ok, item} =
               %{item | url: "https://github.com/github_user/repo/missed"}
               |> Catalog.insert_item()

      refute item.git_source
    end

    test "set git_source for gitlab url", %{item: item} do
      assert {:ok, item} =
               %{item | url: "https://gitlab.com/gitlab_user/repo"}
               |> Catalog.insert_item()

      assert %{git_source: %{gitlab: "gitlab_user/repo"}} = item
    end

    test "leave git_source nilled for regular url", %{item: item} do
      assert {:ok, item} = %{item | url: "https://example.com"} |> Catalog.insert_item()
      refute item.git_source
    end
  end

  describe "update_changeset() validations" do
    setup %{item: item} do
      {:ok, item} = item |> Catalog.insert_item()
      [item: item]
    end

    test "not updated with blank: name, description", %{item: item} do
      assert_update_cant_be_blank(item, ~w(name description)a, &Catalog.update_item/2)
    end

    test "not updated with nil category_id", %{item: item} do
      assert {:error, changeset} = item |> Catalog.update_item(%{category_id: nil})
      assert %{category_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "not updated with not exists category_id", %{item: item} do
      assert {:error, changeset} = item |> Catalog.update_item(%{category_id: 0})
      assert %{category: ["does not exist"]} = errors_on(changeset)
    end

    test "bypass updating url", %{item: item} do
      assert {:ok, updated} = item |> Catalog.update_item(%{url: Faker.Internet.url()})
      assert item.url == updated.url
    end

    test "not updated with negative stars_count", %{item: item} do
      assert {:error, changeset} = item |> Catalog.update_item(%{stars_count: -1})
      assert %{stars_count: ["must be greater than or equal to 0"]} == errors_on(changeset)
    end
  end

  describe "set_updated_in() within update_changeset()" do
    setup %{item: item} do
      {:ok, item} = item |> Catalog.insert_item()
      [item: item]
    end

    test "fill updated_in when pushed_at is provided", %{item: item} do
      assert {:ok, updated_item} =
               item |> Catalog.update_item(%{pushed_at: Timex.now() |> Timex.shift(days: -10)})

      assert updated_item.updated_in == 10
    end
  end
end
