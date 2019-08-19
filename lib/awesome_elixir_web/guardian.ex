defmodule AwesomeElixirWeb.Guardian do
  use Guardian, otp_app: :awesome_elixir
  alias AwesomeElixir.Accounts

  def subject_for_token(%Accounts.User{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :invalid_resource}

  def resource_from_claims(claims) do
    case Accounts.get_user_by_id(claims["sub"]) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defmodule CommonPipeline do
    use Guardian.Plug.Pipeline, otp_app: :awesome_elixir
    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  defmodule AuthenticatedPipeline do
    use Guardian.Plug.Pipeline, otp_app: :awesome_elixir
    plug Guardian.Plug.EnsureAuthenticated
  end

  defmodule NotAuthenticatedPipeline do
    use Guardian.Plug.Pipeline, otp_app: :awesome_elixir
    plug Guardian.Plug.EnsureNotAuthenticated
  end

  defmodule AuthErrorHandler do
    import Plug.Conn
    import Phoenix.Controller, only: [get_format: 1, put_flash: 3, redirect: 2]

    @behaviour Guardian.Plug.ErrorHandler

    @impl Guardian.Plug.ErrorHandler
    def auth_error(conn, {:already_authenticated, :already_authenticated}, _opts) do
      render_response(conn, "Already authenticated")
    end

    @impl Guardian.Plug.ErrorHandler
    def auth_error(conn, {:unauthenticated, :unauthenticated}, _opts) do
      render_response(conn, "Not authenticated")
    end

    @impl Guardian.Plug.ErrorHandler
    def auth_error(conn, {type, reason}, _opts) do
      render_response(conn, inspect({type, reason}))
    end

    defp render_response(conn, message) do
      if get_format(conn) == "html" do
        conn
        |> put_flash(:error, message)
        |> redirect(to: "/")
      else
        body = Jason.encode!(%{message: message})
        send_resp(conn, 401, body)
      end
    end
  end
end
