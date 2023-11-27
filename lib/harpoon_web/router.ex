defmodule HarpoonWeb.Router do
  use HarpoonWeb, :router

  @host System.get_env("PHX_HOST", "localhost:4000")

  @content_security_policy (case Mix.env() do
                              :prod ->
                                "default-src 'self';connect-src wss://#{@host};img-src 'self' blob:;"

                              _ ->
                                "default-src 'self' 'unsafe-eval' 'unsafe-inline';" <>
                                  "connect-src ws://#{@host}:*;" <>
                                  "img-src 'self' blob: data:;"

                                "font-src data:;"
                            end)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HarpoonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => @content_security_policy}
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
