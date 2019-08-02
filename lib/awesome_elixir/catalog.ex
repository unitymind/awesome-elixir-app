defmodule AwesomeElixir.Catalog do
  import Ecto.Query
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item, FilterParams}

  def list_categories(filter_params) do
    build_query(filter_params)
    |> Repo.all()
  end

  def total_categories_count(categories) do
    length(categories)
  end

  def total_items_count(categories) do
    categories
    |> Enum.reduce(0, fn category, acc -> acc + length(category.items) end)
  end

  defp base_query do
    from(categories in Category,
      left_join: items in Item,
      on: categories.id == items.category_id,
      where: items.is_scrapped == true,
      where: items.is_dead == false,
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

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: true, hide_outdated: false})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars or is_nil(item.stars_count)
    )
  end

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: true, hide_outdated: true})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars or is_nil(item.stars_count),
      where: item.updated_in < 365 or is_nil(item.updated_in)
    )
  end

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: false, hide_outdated: false})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars
    )
  end

  defp build_query(%FilterParams{min_stars: min_stars, show_unstarred: false, hide_outdated: true})
       when min_stars != "all" do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars,
      where: item.updated_in < 365 or is_nil(item.updated_in)
    )
  end

  defp build_query(%FilterParams{min_stars: "all", show_unstarred: false, hide_outdated: false}) do
    from([categories, item] in base_query(),
      where: not is_nil(item.stars_count)
    )
  end

  defp build_query(%FilterParams{min_stars: "all", show_unstarred: false, hide_outdated: true}) do
    from([categories, item] in base_query(),
      where: not is_nil(item.stars_count),
      where: item.updated_in < 365 or is_nil(item.updated_in)
    )
  end

  defp build_query(%FilterParams{hide_outdated: true}) do
    from([categories, item] in base_query(),
      where: item.updated_in < 365 or is_nil(item.updated_in)
    )
  end

  defp build_query(%FilterParams{}) do
    base_query()
  end
end
