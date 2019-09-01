defmodule AwesomeElixir.Jobs.UpdateIndex do
  @moduledoc """
  Performs work on updating index data from [https://github.com/h4cc/awesome-elixir](https://github.com/h4cc/awesome-elixir) as source.
  """

  alias AwesomeElixir.{Catalog, Jobs, Scraper}

  @doc """
  Execute update pipeline actions.

  * Clear previously scheduled job
  * Scrape data and update in `AwesomeElixir.Repo`
  * Invalidate `AwesomeElixir.Catalog` caches
  * Schedule update on the next day
  """
  def perform do
    Jobs.clear_scheduled()
    Scraper.update_index()
    Catalog.invalidate_cached()
    Jobs.schedule_update()
    :ok
  rescue
    e in [Scraper.Index.NotFetchedError, HTTPoison.Error] -> {:error, e}
  end
end
