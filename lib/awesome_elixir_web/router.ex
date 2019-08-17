defmodule AwesomeElixirWeb.Router do
  @moduledoc """
  Defines application specific pipelines and routes.
  """
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

  scope "/", AwesomeElixirWeb do
    pipe_through :browser

    get "/", CatalogController, :index
  end

  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: AwesomeElixirWeb.Schema
  end
end
