defmodule AwesomeElixir.Catalog do
  import Ecto.Query
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item}

  def list_categories(min_stars \\ "all") do
    build_query(min_stars)
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

  defp build_query("all") do
    base_query()
  end

  defp build_query(min_stars) when min_stars in ~w(10 50 100 500 1000) do
    from([categories, item] in base_query(),
      where: item.stars_count >= ^min_stars or is_nil(item.stars_count)
    )
  end
end
