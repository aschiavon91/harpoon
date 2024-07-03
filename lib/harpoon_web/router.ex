defmodule HarpoonWeb.Router do
  use HarpoonWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HarpoonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HarpoonWeb do
    pipe_through :browser

    live_session :default do
      live "/sessions", SessionsLive, :index
      live "/*path_info", HomeLive, :index
    end
  end
end
