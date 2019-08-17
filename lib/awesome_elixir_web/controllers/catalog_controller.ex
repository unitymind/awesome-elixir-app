defmodule AwesomeElixirWeb.CatalogController do
  @moduledoc """
  Filter incoming params and prepare data for rendering via `AwesomeElixir.Catalog` context calls.
  """
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

  @doc """
  Filter params and render Catalog index page.
  """
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    conn |> render_index(Catalog.FilterParams.execute(params))
  end

  defp render_index(conn, params) do
    categories = Catalog.list_categories(params)

    counters = %{
      categories: Catalog.categories_count(categories),
      items: Catalog.items_count(categories),
      last_updated_at: Catalog.last_updated_at()
    }

    render(conn, "index.html",
      navigation_filter_list: @navigation_filter_list,
      categories: categories,
      counters: counters,
      params: params |> Map.from_struct()
    )
  end
end
