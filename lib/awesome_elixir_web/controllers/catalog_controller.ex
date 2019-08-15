defmodule AwesomeElixirWeb.CatalogController do
  @moduledoc """
  Filter incoming params and prepare data for rendering via `AwesomeElixir.Catalog` context calls.
  """
  use AwesomeElixirWeb, :controller

  alias AwesomeElixir.Catalog
  alias Ecto.Changeset

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
    conn |> render_index(filter_params(params))
  end

  defp render_index(conn, params) do
    categories = Catalog.list_categories(params)

    counters = %{
      categories: Catalog.total_categories_count(categories),
      items: Catalog.total_items_count(categories),
      last_updated_at: Catalog.last_updated_at()
    }

    render(conn, "index.html",
      navigation_filter_list: @navigation_filter_list,
      categories: categories,
      counters: counters,
      params: params |> Map.from_struct()
    )
  end

  # Validate incoming params and reject fields with errors
  defp filter_params(params) do
    case Catalog.FilterParams.validate(params) do
      %Changeset{valid?: true} = changeset ->
        Changeset.apply_changes(changeset)

      %Changeset{} = changeset ->
        changeset.data |> Map.merge(Map.drop(changeset.changes, Keyword.keys(changeset.errors)))
    end
  end
end
