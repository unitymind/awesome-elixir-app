defmodule AwesomeElixir.Jobs.UpdateIndex do
  @moduledoc """
  Perform work on updating index data from source `README.md`.
  """
  @behaviour Rihanna.Job

  require Logger
  alias AwesomeElixir.{Catalog, Jobs, Scraper}

  @doc """
  Execute update pipeline actions.

  * Clear previously scheduled job
  * Scrape data and update in `AwesomeElixir.Repo`
  * Invalidate `AwesomeElixir.Catalog` caches
  * Schedule update on the next day
  """
  @impl true
  def perform([]) do
    #    Jobs.clear_scheduled()
    Scraper.update_index()
    Catalog.invalidate_cached()
    Jobs.schedule_update()
    :ok
  rescue
    e in [Scraper.Index.NotFetchedError, HTTPoison.Error] -> {:error, e}
  end

  # coveralls-ignore-start
  @impl true
  def retry_at(_failure_reason, _args, attempts) when attempts < 3 do
    due_at = DateTime.add(DateTime.utc_now(), attempts * 5 * 60, :second)
    {:ok, due_at}
  end

  @impl true
  def retry_at(_failure_reason, _args, _attempts) do
    Logger.warn(
      "AwesomeElixir.Jobs.UpdateIndex failed after 3 attempts. Re-schedule within 1 day."
    )

    Jobs.schedule_update()
    :noop
  end

  # coveralls-ignore-stop
end
