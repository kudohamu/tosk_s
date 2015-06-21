defmodule Tosk.Router do
  use Tosk.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Tosk do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Tosk do
    pipe_through :api
    resource "/user", UserController do
    end
    post "/user/login", UserController, :login
  end
end
