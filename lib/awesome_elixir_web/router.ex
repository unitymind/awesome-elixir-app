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

  pipeline :exq_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :exq_router do
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :guardian_common do
    plug AwesomeElixirWeb.Guardian.CommonPipeline
  end

  pipeline :guardian_authenticated do
    plug AwesomeElixirWeb.Guardian.AuthenticatedPipeline
  end

  pipeline :guardian_not_authenticated do
    plug AwesomeElixirWeb.Guardian.NotAuthenticatedPipeline
  end

  pipeline :as_admin do
    plug AwesomeElixirWeb.Plugs.AuthenticatedAsAdmin
  end

  scope "/", AwesomeElixirWeb do
    pipe_through [:browser, :guardian_common]

    get "/", CatalogController, :index
  end

  scope "/", AwesomeElixirWeb do
    pipe_through [:browser, :guardian_common, :guardian_authenticated]

    get "/profile", ProfileController, :show
  end

  scope "/api" do
    pipe_through [:api, :guardian_common]

    forward "/graphql", Absinthe.Plug, schema: AwesomeElixirWeb.Schema
  end

  scope "/auth", AwesomeElixirWeb do
    pipe_through [:browser, :guardian_common, :guardian_authenticated]

    get "/logout", AuthController, :logout
  end

  scope "/auth", AwesomeElixirWeb do
    pipe_through [:browser, :guardian_common, :guardian_not_authenticated]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/exq", ExqUi do
    pipe_through [:exq_browser, :guardian_common, :guardian_authenticated, :as_admin, :exq_router]
    forward "/", RouterPlug.Router, :index
  end
end
