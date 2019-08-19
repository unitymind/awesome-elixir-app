defmodule AwesomeElixirWeb.AuthController do
  @moduledoc """
  Implements `Ueberauth` callback route
  """

  use AwesomeElixirWeb, :controller
  alias AwesomeElixir.Accounts
  alias AwesomeElixirWeb.Guardian

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: fail}} = conn, _params) do
    message = Enum.map(fail.errors, fn %{message: message} -> message end) |> Enum.join(" ")
    redirect_to_with_flash(conn, "/", :error, message)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    {:ok, %Accounts.User{} = user} = Accounts.find_or_create_from_auth(auth)

    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect_to_with_flash(
      "/",
      :success,
      "Successfully authenticated"
    )
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect_to_with_flash("/", :info, "Signed out")
  end
end
