defmodule AwesomeElixirWeb.Router do
  use AwesomeElixirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AwesomeElixirWeb do
    pipe_through :browser

    get "/", CatalogController, :index
  end
end
