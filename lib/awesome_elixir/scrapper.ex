defmodule AwesomeElixir.Scrapper do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item}

  def get_item_by_id(item_id), do: Repo.get(Item, item_id)

  def store_data(data) do
    for {_, category} <- data do
      {:ok, category_from_db} =
        build_changeset_for_category(Map.from_struct(category))
        |> handle_category_changeset()

      for item <- category.items do
        build_changeset_for_item(Map.from_struct(item), category_from_db.id)
        |> handle_item_changeset()
      end
    end
  end

  defp build_changeset_for_category(attributes) do
    case Repo.get_by(Category, slug: attributes.slug) do
      nil -> %Category{}
      entity -> entity
    end
    |> Category.insert_or_update_changeset(attributes)
  end

  defp handle_category_changeset(changeset) do
    changeset |> Repo.insert_or_update()
  end

  defp build_changeset_for_item(attributes, category_id) do
    {item, attrs} =
      case Repo.get_by(Item, url: attributes.url) do
        nil -> {%Item{}, attributes |> Map.put(:category_id, category_id)}
        entity -> {entity, attributes}
      end

    Item.insert_or_update_changeset(item, attrs)
  end

  defp handle_item_changeset(changeset) do
    if map_size(changeset.changes) != 0 do
      {:ok, item_from_db} = Repo.insert_or_update(changeset)

      Exq.enqueue_in(Exq, "default", Enum.random(5..20), AwesomeElixir.Workers.UpdateItem, [
        item_from_db.id
      ])
    end
  end
end
