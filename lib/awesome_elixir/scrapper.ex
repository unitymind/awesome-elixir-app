defmodule AwesomeElixir.Scrapper do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item}

  def get_item_by_id(item_id), do: Repo.get(Item, item_id)

  def store_data(data) do
    for {_, category} <- data do
      {:ok, category_from_db} =
        build_changeset_for_category(category)
        |> handle_category_changeset()

      for item <- category.items do
        build_changeset_for_item(item, category_from_db.id)
        |> handle_item_changeset()
      end
    end
  end

  defp build_changeset_for_category(category) do
    attributes = Map.from_struct(category)

    case Repo.get_by(Category, slug: attributes.slug) do
      nil -> Category.insert_changeset(attributes)
      categories -> Category.update_changeset(categories, attributes)
    end
  end

  defp handle_category_changeset(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.insert_or_update()
  end

  defp build_changeset_for_item(item, category_id) do
    attributes = Map.from_struct(item)

    case Repo.get_by(Item, url: attributes.url) do
      nil ->
        {:insert, Item.insert_changeset(attributes |> Map.put(:category_id, category_id))}

      item_from_db ->
        {:update,
         Item.update_changeset(item_from_db, attributes |> Map.put(:category_id, category_id))
         |> Item.prevent_description_update()}
    end
    |> handle_item_changeset()
  end

  defp handle_item_changeset({:insert, changeset}) do
    Repo.insert(changeset) |> enqueue_scrapper_item_update()
  end

  defp handle_item_changeset({:update, %Ecto.Changeset{changes: changes} = changeset})
       when map_size(changes) > 0 do
    Repo.update(changeset) |> enqueue_scrapper_item_update()
  end

  defp handle_item_changeset(_), do: :ok

  defp enqueue_scrapper_item_update({:ok, item}) do
    Exq.enqueue_in(Exq, "default", Enum.random(5..20), AwesomeElixir.Workers.UpdateItem, [item.id])
  end

  defp enqueue_scrapper_item_update(_), do: :ok
end
