defmodule AwesomeElixirWeb.CatalogView do
  @moduledoc """
  Helper module for `Catalog` view
  """

  use AwesomeElixirWeb, :view

  @doc """
  Render Markdown markup to HTML.
  """
  @spec render_markdown([String.t()]) :: String.t()
  def render_markdown(lines) do
    lines |> Earmark.as_html!(%Earmark.Options{pure_links: false})
  end
end
