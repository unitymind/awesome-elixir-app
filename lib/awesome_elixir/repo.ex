defmodule AwesomeElixir.Repo do
  alias AwesomeElixir.Catalog.{Category, Item}

  use Ecto.Repo,
    otp_app: :awesome_elixir,
    adapter: Ecto.Adapters.Postgres

  def get_item_by_id(item_id), do: get(Item, item_id)
  def get_item_by_url(url), do: get_by(Item, url: url)
  def get_category_by_slug(slug), do: get_by(Category, slug: slug)

  def store_index(data) do
    for category <- data, item <- category.items do
      with {:ok, category_from_db} <-
             build_changeset_for_category(category) |> handle_category_changeset() do
        build_changeset_for_item(item, category_from_db.id)
        |> handle_item_changeset()
      end
    end
  end

  defp build_changeset_for_category(category) do
    attributes = Map.from_struct(category)

    case get_category_by_slug(attributes.slug) do
      category when is_map(category) ->
        Category.update_changeset(category, attributes)

      _ ->
        Category.insert_changeset(attributes)
    end
  end

  defp handle_category_changeset(%Ecto.Changeset{} = changeset) do
    insert_or_update(changeset)
  end

  defp build_changeset_for_item(item, category_id) do
    attributes = Map.from_struct(item) |> Map.put(:category_id, category_id)

    case get_item_by_url(attributes.url) do
      item_from_db when is_map(item_from_db) ->
        {:update,
         item_from_db
         |> Item.update_changeset(attributes)
         |> Item.prevent_description_update()}

      _ ->
        {:insert, Item.insert_changeset(attributes)}
    end
    |> handle_item_changeset()
  end

  defp handle_item_changeset({:insert, changeset}) do
    insert(changeset)
    |> enqueue_scraper_item_update()
  end

  defp handle_item_changeset({:update, %Ecto.Changeset{changes: changes} = changeset})
       when map_size(changes) > 0 do
    update(changeset)
    |> enqueue_scraper_item_update()
  end

  defp handle_item_changeset(_), do: :ok

  defp enqueue_scraper_item_update({:ok, item}) do
    Exq.enqueue_in(Exq, "default", Enum.random(5..20), AwesomeElixir.Workers.UpdateItem, [item.id])
  end

  defp enqueue_scraper_item_update(_), do: :ok
end
