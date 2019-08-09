defmodule AwesomeElixir.Scraper do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Scraper.{Index, Item}

  def update_index do
    with data when is_list(data) <- Index.update(), do: Repo.store_index(data)
  end

  def update_item(item_id) do
    with item when is_map(item) <- Repo.get_item_by_id(item_id), do: Item.update(item)
  end
end
