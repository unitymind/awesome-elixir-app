defmodule AwesomeElixir.Catalog do
  import Ecto.Query
  use Memoize
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item, FilterParams}

  def get_item_by_id(item_id), do: Repo.get(Item, item_id)
  def get_item_by_url(url), do: Repo.get_by(Item, url: url)
  def get_category_by_slug(slug), do: Repo.get_by(Category, slug: slug)

  @spec insert_item(Item.t()) :: term()
  def insert_item(%Item{} = item) do
    item
    |> Map.from_struct()
    |> Item.insert_changeset()
    |> Repo.insert()
  end

  @spec update_item(Item.t(), map()) :: term()
  def update_item(%Item{} = item, %{} = changes) do
    Item.update_changeset(item, changes)
    |> Repo.update()
  end

  @spec insert_item(Category.t()) :: term()
  def insert_category(%Category{} = category) do
    category
    |> Map.from_struct()
    |> Category.insert_changeset()
    |> Repo.insert()
  end

  @spec list_categories(FilterParams.t()) :: [Category.t()]
  defmemo list_categories(filter_params) do
    build_query(filter_params)
    |> filter_by_updated_in(filter_params)
    |> Repo.all()
  end

  @spec total_categories_count([Category.t()]) :: non_neg_integer()
  defmemo total_categories_count(categories) do
    length(categories)
  end

  @spec total_items_count([Category.t()]) :: non_neg_integer()
  defmemo total_items_count(categories) do
    Enum.reduce(categories, 0, fn %{items: items}, acc -> acc + length(items) end)
  end

  @spec last_updated_at() :: String.t() | DateTime.t()
  defmemo last_updated_at do
    case Repo.one(
           from item in Item, order_by: [desc: item.updated_at], select: [:updated_at], limit: 1
         ) do
      %Item{updated_at: updated_at} -> updated_at
      _ -> "never"
    end
  end

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
