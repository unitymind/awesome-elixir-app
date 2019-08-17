defmodule AwesomeElixirWeb.SharedView do
  @moduledoc false
  use AwesomeElixirWeb, :view

  def app_version, do: Application.spec(:awesome_elixir, :vsn)
end
