defmodule AwesomeElixirWeb.SharedView do
  @moduledoc false
  use AwesomeElixirWeb, :view
  use Memoize

  defmemo app_version(), do: Application.spec(:awesome_elixir, :vsn)
end
