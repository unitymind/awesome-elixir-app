defmodule AwesomeElixirWeb.AuthController do
  @moduledoc """
  Filter incoming params and prepare data for rendering via `AwesomeElixir.Catalog` context calls.
  """
  use AwesomeElixirWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: fail}} = conn, _params) do
    conn
    |> text("Auth Fail: #{inspect(fail)}}")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    text(conn, "Auth OK: #{inspect(auth)}}")
  end
end
