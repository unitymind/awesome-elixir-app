defmodule AwesomeElixirWeb.AuthController do
  @moduledoc """
  Implements `Ueberauth` callback route and application `logout` action.
  """

  use AwesomeElixirWeb, :controller
  alias AwesomeElixir.Accounts
  alias AwesomeElixirWeb.Guardian

  plug Ueberauth

  @doc """
  Handle specific assigns from `Ueberauth` plug as a part of OAuth flow.

    * On failure: extracts error message and redirect to root with flash message
    * On success: retrieve or create `AwesomeElixir.Accounts.User` based on `Ueberauth.Auth` data,
      then make `AwesomeElixirWeb.Guardian.Plug.sign_in/2` call and redirect to root with flash message
  """
  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_failure: fail}} = conn, _params) do
    message = Enum.map(fail.errors, fn %{message: message} -> message end) |> Enum.join(" ")
    redirect_to_with_flash(conn, "/", :error, message)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    {:ok, %Accounts.User{} = user} = Accounts.find_or_create_user_from_auth(auth)

    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect_to_with_flash(
      "/",
      :success,
      "Successfully authenticated"
    )
  end

  @doc """
  Make `AwesomeElixirWeb.Guardian.Plug.sign_out/1` call and redirect to root with flash message.
  """
  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect_to_with_flash("/", :info, "Signed out")
  end
end
