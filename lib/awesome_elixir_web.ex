defmodule AwesomeElixirWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AwesomeElixirWeb, :controller
      use AwesomeElixirWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: AwesomeElixirWeb

      import Plug.Conn
      import AwesomeElixirWeb.Gettext
      alias AwesomeElixirWeb.Router.Helpers, as: Routes

      # FIXME. Refactor to helper module
      def redirect_to_with_flash(conn, to, flash_key, flash_message) do
        conn
        |> put_flash(flash_key, flash_message)
        |> redirect(to: to)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/awesome_elixir_web/templates",
        namespace: AwesomeElixirWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import AwesomeElixirWeb.ErrorHelpers
      import AwesomeElixirWeb.Gettext
      alias AwesomeElixirWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AwesomeElixirWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  # coveralls-ignore-start
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  # coveralls-ignore-stop
end
