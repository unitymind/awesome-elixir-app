defmodule AwesomeElixir.Scraper do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Scraper.Index

  def update_index do
    with data when is_list(data) <- Index.update(), do: Repo.store_index(data)
  end
end
