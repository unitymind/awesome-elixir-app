defmodule AwesomeElixirWeb.Schema do
  use Absinthe.Schema

  import_types AwesomeElixirWeb.Schema.CatalogTypes

  query do
    import_fields(:catalog_queries)
  end
end
