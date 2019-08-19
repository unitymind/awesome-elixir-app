defmodule AwesomeElixirWeb.SharedView do
  @moduledoc false
  use AwesomeElixirWeb, :view

  def app_version, do: Application.spec(:awesome_elixir, :vsn)

  def show_notification(conn) do
    conn
    |> get_flash
    |> flash_message
  end

  def flash_message(%{"info" => message}) do
    render("notification.html", class: "primary", message: message)
  end

  def flash_message(%{"error" => message}) do
    render("notification.html", class: "danger", message: message)
  end

  def flash_message(%{"success" => message}) do
    render("notification.html", class: "success", message: message)
  end

  def flash_message(_), do: nil
end
