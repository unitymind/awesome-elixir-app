defmodule AwesomeElixirWeb.LayoutView do
  @moduledoc """
  Implements `Layout` view helpers.
  """
  use AwesomeElixirWeb, :view

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
