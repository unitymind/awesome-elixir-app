defmodule AwesomeElixir.Scrapper do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item}

  def get_item_by_id(item_id), do: Repo.get(Item, item_id)

  def store_data(data) do
    Enum.each(data, fn {_, category} ->
      attributes = Map.from_struct(category)

      {:ok, category_from_db} =
        case Repo.get_by(Category, slug: category.slug) do
          nil ->
            Category.insert_or_update_changeset(%Category{}, attributes)

          entity ->
            Category.insert_or_update_changeset(entity, attributes |> Map.delete(:slug))
        end
        |> Repo.insert_or_update()

      Enum.each(category.items, fn item ->
        attributes = Map.from_struct(item)

        changeset =
          case Repo.get_by(Item, url: item.url) do
            nil ->
              Item.insert_or_update_changeset(
                %Item{},
                attributes |> Map.put(:category_id, category_from_db.id)
              )

            entity ->
              Item.insert_or_update_changeset(entity, attributes |> Map.delete(:url))
          end

        if map_size(changeset.changes) != 0 do
          {:ok, item_from_db} = Repo.insert_or_update(changeset)

          Exq.enqueue_in(Exq, "default", Enum.random(5..20), AwesomeElixir.Workers.UpdateItem, [
            item_from_db.id
          ])
        end
      end)
    end)
  end
end
