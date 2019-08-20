defmodule AwesomeElixirWeb.ProfileController do
  @moduledoc """
  Implements Profile actions.
  """

  use AwesomeElixirWeb, :controller

  def index(conn, _) do
    redirect_to_with_flash(conn, "/", :error, "Not yet implemented")
  end
end
