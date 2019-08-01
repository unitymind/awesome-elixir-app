defmodule AwesomeElixirWeb.CatalogController do
  use AwesomeElixirWeb, :controller
  alias AwesomeElixir.Catalog

  @navigation_filter_list [
    {"all", "All"},
    {"10", "10"},
    {"50", "50"},
    {"100", "100"},
    {"500", "500"},
    {"1000", "1000"}
  ]

  def index(conn, %{"min_stars" => min_stars}) when min_stars in ~w(all 10 50 100 500 1000) do
    render_index(conn, min_stars)
  end

  def index(conn, _params) do
    render_index(conn, "all")
  end

  defp render_index(conn, min_stars) do
    categories = Catalog.list_categories(min_stars)
    total_categories_count = Catalog.total_categories_count(categories)
    total_items_count = Catalog.total_items_count(categories)

    render(conn, "index.html",
      navigation_filter_list: @navigation_filter_list,
      categories: categories,
      total_categories_count: total_categories_count,
      total_items_count: total_items_count,
      min_stars: min_stars
    )
  end
end
