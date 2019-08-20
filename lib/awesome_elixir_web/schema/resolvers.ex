defmodule AwesomeElixirWeb.Schema.Resolvers do
  @moduledoc """
  Implements GraphQL resolvers for queries.
  """

  alias AwesomeElixir.Catalog

  @doc """
  List categories with applied filters from `params`.
  """
  @spec list_categories(map(), Absinthe.Resolution.t()) :: {:ok, map()}
  def list_categories(params, _) do
    categories = Catalog.FilterParams.execute(params) |> Catalog.list_categories()

    {:ok,
     %{
       entities: categories,
       categories_count: Catalog.categories_count(categories),
       items_count: Catalog.items_count(categories),
       last_updated_at: Catalog.last_updated_at()
     }}
  end
end
