defmodule AwesomeElixirWeb.ProfileController do
  @moduledoc """
  Implements Profile actions.
  """

  use AwesomeElixirWeb, :controller
  alias AwesomeElixirWeb.Guardian

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, _) do
    render(conn, "show.html",
      profile: Guardian.Plug.current_resource(conn).profile
    )
  end
end
