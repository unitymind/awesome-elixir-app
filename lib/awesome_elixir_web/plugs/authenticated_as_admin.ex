defmodule AwesomeElixirWeb.Plugs.AuthenticatedAsAdmin do
  alias AwesomeElixirWeb.Policy

  import Plug.Conn
  import Phoenix.Controller, only: [get_format: 1, put_flash: 3, redirect: 2]
  import AwesomeElixirWeb.ControllerHelpers

  def init(opts), do: opts

  def call(conn, _opts) do
    case Bodyguard.permit(Policy, :exq_scope, Guardian.Plug.current_resource(conn)) do
      :ok ->
        conn

      {:error, :unauthorized} ->
        message = "Not permitted"

        if get_format(conn) == "html" do
          conn
          |> redirect_to_with_flash("/", :error, message)
          |> halt()
        else
          conn
          |> send_resp(403, Jason.encode!(%{message: message}))
          |> halt()
        end
    end
  end
end
