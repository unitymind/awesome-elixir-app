defmodule AwesomeElixir.Catalog.ItemTest do
  use AwesomeElixir.DataCase
  import AwesomeElixir.Factory
  alias AwesomeElixir.Catalog.{Category, Item}

  setup do
    category =
      build(:category)
      |> Map.from_struct()
      |> Category.insert_changeset()
      |> Repo.insert!()

    item = build(:item, category_id: category.id)

    [item: item]
  end

  describe "insert_changeset() validations" do
    test "not inserted with blank: name, url, description", %{item: item} do
      assert_insert_cant_be_blank(item, ~w(name url description)a, &insert_item/1)
    end

    test "not inserted with nil category_id", %{item: item} do
      {:error, changeset} = %{item | category_id: nil} |> insert_item()
      assert "can't be blank" in errors_on(changeset).category_id
    end

    test "not inserted with not exists category_id", %{item: item} do
      {:error, changeset} = %{item | category_id: 0} |> insert_item()

      assert "does not exist" in errors_on(changeset).category
    end

    test "not inserted with invalid url", %{item: item} do
      {:error, changeset} =
        %{item | url: "http://example.com\\blog\\first"}
        |> insert_item()

      assert "is invalid" in errors_on(changeset).url
    end

    test "not inserted with duplicate url", %{item: item} do
      {:ok, _} = insert_item(item)

      {:error, changeset} = insert_item(item)
      assert "has already been taken" in errors_on(changeset).url
    end
  end

  describe "set_git_source() within insert_changeset()" do
    test "set git_source for github url", %{item: item} do
      {:ok, item} =
        %{item | url: "https://github.com/github_user/repo"}
        |> insert_item()

      assert item.git_source.github == "github_user/repo"
    end

    test "set git_source for gitlab url", %{item: item} do
      {:ok, item} =
        %{item | url: "https://gitlab.com/gitlab_user/repo"}
        |> insert_item()

      assert item.git_source.gitlab == "gitlab_user/repo"
    end

    test "leave git_source nilled for regular url", %{item: item} do
      {:ok, item} = %{item | url: "https://example.com"} |> insert_item()

      refute item.git_source
    end
  end

  describe "update_changeset() validations" do
    setup %{item: item} do
      {:ok, item} = item |> insert_item()
      [item: item]
    end

    test "not updated with blank: name, description", %{item: item} do
      assert_update_cant_be_blank(item, ~w(name description)a, &update_item/2)
    end

    test "not updated with nil category_id", %{item: item} do
      {:error, changeset} = item |> update_item(%{category_id: nil})
      assert "can't be blank" in errors_on(changeset).category_id
    end

    test "not updated with not exists category_id", %{item: item} do
      {:error, changeset} = item |> update_item(%{category_id: 0})
      assert "does not exist" in errors_on(changeset).category
    end

    test "bypass updating url", %{item: item} do
      {:ok, updated} = item |> update_item(%{url: Faker.Internet.url()})
      assert item.url == updated.url
    end

    test "not updated with negative stars_count", %{item: item} do
      {:error, changeset} = item |> update_item(%{stars_count: -1})
      assert "must be greater than or equal to 0" in errors_on(changeset).stars_count
    end
  end

  describe "set_updated_in() within update_changeset()" do
    setup %{item: item} do
      {:ok, item} = item |> insert_item()
      [item: item]
    end

    test "fill updated_in when pushed_at is provided", %{item: item} do
      {:ok, updated_item} =
        item |> update_item(%{pushed_at: Timex.now() |> Timex.shift(days: -10)})

      assert updated_item.updated_in == 10
    end
  end

  defp insert_item(%Item{} = item) do
    item
    |> Map.from_struct()
    |> Item.insert_changeset()
    |> Repo.insert()
  end

  defp update_item(%Item{} = item, %{} = changes) do
    Item.update_changeset(item, changes)
    |> Repo.update()
  end
end
