defmodule AwesomeElixirWeb.Router do
  use AwesomeElixirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug BasicAuth, use_config: {:exq_ui, :basic_auth}
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/", AwesomeElixirWeb do
    pipe_through :browser

    get "/", CatalogController, :index
  end

  scope "/exq", ExqUi do
    pipe_through :exq
    forward "/", RouterPlug.Router, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AwesomeElixirWeb do
  #   pipe_through :api
  # end
end
