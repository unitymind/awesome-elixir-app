defmodule AwesomeElixir.Workers.UpdateIndex do
  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper
  alias AwesomeElixir.Workers

  def perform do
    Workers.clear_scheduled()
    Scraper.update_index()
    Catalog.invalidate_cached()
    Workers.schedule_update()
  end
end
