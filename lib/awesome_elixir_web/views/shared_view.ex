defmodule AwesomeElixirWeb.SharedView do
  @moduledoc """
  Helper module for `Shared` view.
  """

  use AwesomeElixirWeb, :view

  @doc """
  Returns application version.
  """
  @spec app_version() :: Application.value()
  def app_version, do: Application.spec(:awesome_elixir, :vsn)

  @doc """
  Render notification block according to flash value.
  """
  @spec show_notification(Plug.Conn.t()) :: Plug.Conn.t()
  def show_notification(conn) do
    conn
    |> get_flash()
    |> flash_message()
  end

  defp flash_message(%{"info" => message}) do
    render("notification.html", class: "primary", message: message)
  end

  defp flash_message(%{"error" => message}) do
    render("notification.html", class: "danger", message: message)
  end

  defp flash_message(%{"success" => message}) do
    render("notification.html", class: "success", message: message)
  end

  defp flash_message(_), do: nil
end
