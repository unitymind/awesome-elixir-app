defmodule AwesomeElixirWeb.Schema do
  @moduledoc """
  Describes application specific `Absinthe.Schema` (GraphQL).
  """

  use Absinthe.Schema
  import_types AwesomeElixirWeb.Schema.CatalogTypes

  query do
    import_fields(:catalog_queries)
  end
end
