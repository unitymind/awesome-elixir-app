defmodule AwesomeElixir.Scraper do
  @moduledoc """
  Acts as context module for scraping and update data.
  """

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Jobs
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Scraper.{Index, Item}

  @doc """
  Updating index data from source `README.md`.
  """
  @spec update_index() :: :ok | :error
  def update_index do
    with data when is_list(data) <- Index.update() do
      store_index(data)
      :ok
    else
      _ ->
        :error
    end
  end

  @doc """
  Updating item data from source url for a given `item_id`.
  """
  @spec update_item(integer()) :: :ok | :error
  def update_item(item_id) do
    with item when is_map(item) <- Catalog.get_item_by_id(item_id) do
      Item.update(item)
      :ok
    else
      _ ->
        :error
    end
  end

  defp store_index(data) do
    for category <- data do
      {:ok, category_from_db} =
        build_changeset_for_category(category) |> handle_category_changeset()

      for item <- category.items do
        build_changeset_for_item(item, category_from_db.id) |> handle_item_changeset()
      end
    end
  end

  defp build_changeset_for_category(category) do
    attributes = Map.from_struct(category)

    case Catalog.get_category_by_slug(attributes.slug) do
      category when is_map(category) ->
        Catalog.Category.update_changeset(category, attributes)

      _ ->
        Catalog.Category.insert_changeset(attributes)
    end
  end

  defp handle_category_changeset(%Ecto.Changeset{} = changeset) do
    Repo.insert_or_update(changeset)
  end

  defp build_changeset_for_item(item, category_id) do
    attributes = Map.from_struct(item) |> Map.put(:category_id, category_id)

    case Catalog.get_item_by_url(attributes.url) do
      item_from_db when is_map(item_from_db) ->
        {:update,
         item_from_db
         |> Catalog.Item.update_changeset(attributes)
         |> prevent_description_update()}

      _ ->
        {:insert, Catalog.Item.insert_changeset(attributes)}
    end
    |> handle_item_changeset()
  end

  defp prevent_description_update(%Ecto.Changeset{data: %{is_scrapped: true}} = changeset) do
    changeset
    |> Ecto.Changeset.delete_change(:description)
  end

  defp prevent_description_update(changeset), do: changeset

  defp handle_item_changeset({:insert, changeset}) do
    Repo.insert(changeset)
    |> enqueue_scraper_item_update()
  end

  # FIXME. Cover it!
  # coveralls-ignore-start
  defp handle_item_changeset({:update, %Ecto.Changeset{changes: changes} = changeset})
       when map_size(changes) > 0 do
    Repo.update(changeset)
    |> enqueue_scraper_item_update()
  end

  # coveralls-ignore-stop

  defp handle_item_changeset(_), do: :ok

  defp enqueue_scraper_item_update({:ok, item}) do
    Jobs.retry_item_in(item.id, Enum.random(5..20))
  end

  defp enqueue_scraper_item_update(_), do: :ok
end
