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
      live "/", HomeLive, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", HarpoonWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard preview in development
  if Application.compile_env(:harpoon, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HarpoonWeb.Telemetry
    end
  end
end
