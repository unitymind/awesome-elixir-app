defmodule AwesomeElixir.Catalog.CategoryTest do
  use AwesomeElixir.DataCase, async: true
  alias AwesomeElixir.Catalog

  import AwesomeElixir.Support.Assertions
  import AwesomeElixir.Support.Helpers

  setup do
    [category: build(:category)]
  end

  describe "insert_changeset() validations" do
    test "not inserted with blank: name, url, slug", %{category: category} do
      assert_insert_cant_be_blank(
        category,
        ~w(name slug description)a,
        &Catalog.insert_category/1
      )
    end

    test "not inserted with duplicate slug", %{category: category} do
      {:ok, _} = Catalog.insert_category(category)

      {:error, changeset} = Catalog.insert_category(category)
      assert "has already been taken" in errors_on(changeset).slug
    end
  end

  describe "update_changeset() validations" do
    setup %{category: category} do
      {:ok, category} = category |> Catalog.insert_category()
      [category: category]
    end

    test "not updated with blank: name, description", %{category: category} do
      assert_update_cant_be_blank(
        category,
        ~w(name description)a,
        &Catalog.update_category/2
      )
    end

    test "bypass updating slug", %{category: category} do
      {:ok, updated} = category |> Catalog.update_category(%{slug: build(:category).slug})
      assert category.slug == updated.slug
    end
  end
end
