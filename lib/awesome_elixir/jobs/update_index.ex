defmodule AwesomeElixir.Jobs.UpdateIndex do
  @moduledoc """
  Perform work on updating index data from source `README.md`.
  """
  @behaviour Rihanna.Job

  require Logger

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper
  alias AwesomeElixir.Jobs

  @doc """
  Execute update pipeline actions.

  * Clear previously scheduled job
  * Scrape data and update in `AwesomeElixir.Repo`
  * Invalidate `AwesomeElixir.Catalog` caches
  * Schedule update on the next day
  """
  @impl true
  def perform([]) do
    Jobs.clear_scheduled()
    Scraper.update_index()
    Catalog.invalidate_cached()
    Jobs.schedule_update()
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
