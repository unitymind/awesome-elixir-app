defmodule AwesomeElixir.Workers.UpdateItem do
  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper
  alias AwesomeElixir.Workers

  def perform(item_id) do
    Workers.clear_scheduled(item_id)

    with {result, data} when result == :retry or result == :ok <- Scraper.update_item(item_id) do
      cond do
        {:retry, :now} == {result, data} ->
          Workers.retry_item_in(item_id, Enum.random(50..70))

        result == :retry ->
          Workers.retry_item_at(item_id, data)

        result == :ok ->
          Catalog.invalidate_cached()
          Workers.schedule_update(item_id)
      end
    end
  end
end
