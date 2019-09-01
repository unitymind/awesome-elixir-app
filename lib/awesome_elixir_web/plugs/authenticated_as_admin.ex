defmodule AwesomeElixirWeb.Plugs.AuthenticatedAsAdmin do
  alias AwesomeElixirWeb.Policy

  import Plug.Conn
  import Phoenix.Controller, only: [get_format: 1, put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)

    case Bodyguard.permit(Policy, :exq_scope, current_user) do
      :ok ->
        conn

      {:error, :unauthorized} ->
        message = "Not permitted"

        if get_format(conn) == "html" do
          conn
          |> put_flash(:error, message)
          |> redirect(to: "/")
          |> halt()
        else
          conn
          |> send_resp(403, Jason.encode!(%{message: message}))
          |> halt()
        end
    end
  end
end
