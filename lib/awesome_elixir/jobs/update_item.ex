defmodule AwesomeElixir.Jobs.UpdateItem do
  @behaviour Rihanna.Job

  require Logger

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper
  alias AwesomeElixir.Jobs

  @impl true
  def perform([item_id]) do
    Jobs.clear_scheduled(item_id)

    with {result, data} when result in [:retry, :ok] <- Scraper.update_item(item_id) do
      cond do
        {:retry, :now} == {result, data} ->
          Jobs.retry_item_in(item_id, Enum.random(50..70))

        result == :retry ->
          Jobs.retry_item_at(item_id, data)

        result == :ok ->
          Catalog.invalidate_cached()
          Jobs.schedule_update(item_id)
      end
    end

    :ok
  end

  # coveralls-ignore-start
  @impl true
  def retry_at(_failure_reason, _args, attempts) when attempts < 3 do
    due_at = DateTime.add(DateTime.utc_now(), attempts * 5, :second)
    {:ok, due_at}
  end

  @impl true
  def retry_at(_failure_reason, _args, _attempts) do
    Logger.warn("Job failed after 3 attempts")
    :noop
  end

  # coveralls-ignore-stop
end
