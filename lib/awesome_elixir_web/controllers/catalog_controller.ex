defmodule AwesomeElixirWeb.CatalogController do
  @moduledoc """
  Filter incoming params and prepare data for rendering via `AwesomeElixir.Catalog` context calls.
  """

  use AwesomeElixirWeb, :controller
  alias AwesomeElixir.Catalog

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
      items: Catalog.items_count(categories)
    }

    render(conn, "index.html",
      categories: categories,
      counters: counters
    )
  end
end
