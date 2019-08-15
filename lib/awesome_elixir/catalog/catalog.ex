defmodule AwesomeElixir.Catalog do
  @moduledoc """
    Acts as context module for accessing to `AwesomeElixir.Catalog.Category` and `AwesomeElixir.Catalog.Item` entities.
  """

  import Ecto.Query
  use Memoize
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item, FilterParams}

  @doc """
  Get `AwesomeElixir.Catalog.Item` from `AwesomeElixir.Repo` by `id`
  """
  @spec get_item_by_id(integer()) :: Item.t() | nil
  def get_item_by_id(item_id), do: Repo.get(Item, item_id)

  @doc """
  Get `AwesomeElixir.Catalog.Item` from `AwesomeElixir.Repo` by `url`
  """
  @spec get_item_by_url(String.t()) :: Item.t() | nil
  def get_item_by_url(url), do: Repo.get_by(Item, url: url)

  @doc """
  Get `AwesomeElixir.Catalog.Category` from `AwesomeElixir.Repo` by `slug`
  """
  @spec get_category_by_slug(String.t()) :: Category.t() | nil
  def get_category_by_slug(slug), do: Repo.get_by(Category, slug: slug)

  @doc """
  Insert `AwesomeElixir.Catalog.Item` to `AwesomeElixir.Repo`, using `AwesomeElixir.Catalog.Item.insert_changeset/1`
  """
  @spec insert_item(Item.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def insert_item(%Item{} = item) do
    item
    |> Map.from_struct()
    |> Item.insert_changeset()
    |> Repo.insert()
  end

  @doc """
  Update `AwesomeElixir.Catalog.Item` in `AwesomeElixir.Repo`,  using `AwesomeElixir.Catalog.Item.update_changeset/2`
  """
  @spec update_item(Item.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(%Item{} = item, %{} = changes) do
    Item.update_changeset(item, changes)
    |> Repo.update()
  end

  @doc """
  Insert `AwesomeElixir.Catalog.Category` to `AwesomeElixir.Repo`, using `AwesomeElixir.Catalog.Category.insert_changeset/1`
  """
  @spec insert_category(Category.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def insert_category(%Category{} = category) do
    category
    |> Map.from_struct()
    |> Category.insert_changeset()
    |> Repo.insert()
  end

  @doc """
  Update `AwesomeElixir.Catalog.Category` in `AwesomeElixir.Repo`, using `AwesomeElixir.Catalog.Item.update_changeset/2`
  """
  @spec update_category(Category.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_category(%Category{} = category, %{} = changes) do
    Category.update_changeset(category, changes)
    |> Repo.update()
  end

  @doc """
  List `AwesomeElixir.Catalog.Category` from `AwesomeElixir.Repo` by applying `AwesomeElixir.Catalog.FilterParams`
  """
  @spec list_categories(FilterParams.t()) :: [Category.t()]
  defmemo list_categories(filter_params) do
    build_query(filter_params)
    |> filter_by_updated_in(filter_params)
    |> Repo.all()
  end

  @doc """
  Count all `AwesomeElixir.Catalog.Category` according to filtered dataset from `list_categories/1`
  """
  @spec total_categories_count([Category.t()]) :: non_neg_integer()
  defmemo total_categories_count(categories) do
    length(categories)
  end

  @doc """
  Count `AwesomeElixir.Catalog.Item` for all `AwesomeElixir.Catalog.Category` according to filtered dataset from `list_categories/1`
  """
  @spec total_items_count([Category.t()]) :: non_neg_integer()
  defmemo total_items_count(categories) do
    Enum.reduce(categories, 0, fn %{items: items}, acc -> acc + length(items) end)
  end

  @doc """
  Returns `DateTime` for last updated `AwesomeElixir.Catalog.Item` or `never` for empty dataset
  """
  @spec last_updated_at() :: String.t() | DateTime.t()
  defmemo last_updated_at do
    case Repo.one(
           from item in Item, order_by: [desc: item.updated_at], select: [:updated_at], limit: 1
         ) do
      %Item{updated_at: updated_at} -> updated_at
      _ -> "never"
    end
  end

  @doc """
  Invalidate memoization for `list_categories/1`, `total_categories_count/1`, `total_items_count/1` and `last_updated_at/0` calls
  """
  def invalidate_cached do
    for method <- ~w(list_categories total_categories_count total_items_count last_updated_at)a do
      Memoize.invalidate(AwesomeElixir.Catalog, method)
    end
  end

  defp base_query do
    from(categories in Category,
      left_join: items in Item,
      on: categories.id == items.category_id,
      where: items.is_scrapped == true and items.is_dead == false,
      order_by: [categories.name, items.name],
      select: [
        :id,
        :name,
        :slug,
        :description,
        items: [:id, :category_id, :name, :description, :url, :stars_count, :updated_in]
      ],
      preload: [items: items]
    )
  end

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: true})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars or is_nil(item.stars_count)
    )
  end

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: false})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars
    )
  end

  defp build_query(%FilterParams{min_stars: "all", show_unstarred: false}) do
    from([categories, item] in base_query(),
      where: not is_nil(item.stars_count)
    )
  end

  defp build_query(%FilterParams{}), do: base_query()

  defp filter_by_updated_in(query, %FilterParams{show_just_updated: true}) do
    from([categories, item] in query,
      where: item.updated_in <= 7 or is_nil(item.updated_in)
    )
  end

  defp filter_by_updated_in(query, %FilterParams{hide_outdated: true}) do
    from([categories, item] in query,
      where: item.updated_in < 365 or is_nil(item.updated_in)
    )
  end

  defp filter_by_updated_in(query, %FilterParams{}), do: query
end
