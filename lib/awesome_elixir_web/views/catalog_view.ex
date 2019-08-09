defmodule AwesomeElixirWeb.CatalogView do
  use AwesomeElixirWeb, :view

  def render_markdown(lines) do
    lines |> Earmark.as_html!(%Earmark.Options{pure_links: false})
  end
end
