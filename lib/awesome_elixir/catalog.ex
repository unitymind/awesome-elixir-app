defmodule AwesomeElixir.Catalog do
  import Ecto.Query
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item, FilterParams}

  def list_categories(filter_params) do
    build_query(filter_params)
    |> filter_by_updated_in(filter_params)
    |> Repo.all()
  end

  def total_categories_count(categories) do
    length(categories)
  end

  def total_items_count(categories) do
    Enum.reduce(categories, 0, fn category, acc -> acc + length(category.items) end)
  end

  def last_updated_at do
    case Repo.one(
           from item in Item, order_by: [desc: item.updated_at], select: [:updated_at], limit: 1
         ) do
      %Item{updated_at: updated_at} -> updated_at
      _ -> "never"
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
