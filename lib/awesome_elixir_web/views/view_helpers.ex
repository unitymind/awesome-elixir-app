defmodule AwesomeElixirWeb.ViewHelpers do
  @moduledoc """
  Implements common view helpers.
  """

  alias AwesomeElixir.Catalog
  alias AwesomeElixirWeb.Guardian

  @min_stars_filter_list [
    {"all", "All"},
    {"10", "10"},
    {"50", "50"},
    {"100", "100"},
    {"500", "500"},
    {"1000", "1000"}
  ]

  @doc """
  Render Markdown markup as HTML.
  """
  @spec render_markdown([String.t()]) :: String.t()
  def render_markdown(lines) do
    lines |> Earmark.as_html!(%Earmark.Options{pure_links: false})
  end

  @doc """
  Current authenticated user or nil otherwise.
  """
  @spec current_user(Plug.Conn.t()) :: AwesomeElixir.Accounts.User.t() | nil
  def current_user(conn), do: Guardian.Plug.current_resource(conn)

  @doc """
  Filtered query params (via `AwesomeElixir.Catalog.FilterParams.execute/1`).
  """
  @spec filtered_params(Plug.Conn.t()) :: map()
  def filtered_params(conn) do
    conn.params
    |> Catalog.FilterParams.execute()
    |> Map.from_struct()
  end

  @doc """
  Data for rendering min stars navigation filter.
  """
  @spec min_stars_filter_list() :: [tuple()]
  def min_stars_filter_list, do: @min_stars_filter_list

  @doc """
  `DateTime` for last updated `AwesomeElixir.Catalog.Item` or `:never` for empty dataset.
  """
  @spec last_updated_at() :: :never | DateTime.t()
  def last_updated_at, do: Catalog.last_updated_at()

  @doc """
  Application version.
  """
  @spec app_version() :: Application.value()
  def app_version, do: Application.spec(:awesome_elixir, :vsn)
end
