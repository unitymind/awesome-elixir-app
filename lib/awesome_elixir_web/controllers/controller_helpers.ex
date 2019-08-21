defmodule AwesomeElixirWeb.ControllerHelpers do
  @moduledoc """
  Common helpers which imported in `use AwesomeElixirWeb, :controller`
  """

  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  @doc """
    Put flash with specified `key` and `message`, then redirect to given `to` arg.
  """
  @spec redirect_to_with_flash(Plug.Conn.t(), String.t(), atom(), String.t()) :: Plug.Conn.t()
  def redirect_to_with_flash(conn, to, key, message) do
    conn
    |> put_flash(key, message)
    |> redirect(to: to)
  end
end
