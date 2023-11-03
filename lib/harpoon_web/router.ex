defmodule HarpoonWeb.Router do
  use HarpoonWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HarpoonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :ensure_session_id
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

  # Enable LiveDashboard and Swoosh mailbox preview in development
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
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def ensure_session_id(%Plug.Conn{params: %{"sid" => sid}} = conn, _) do
    case Ecto.UUID.cast(sid) do
      {:ok, _} -> sid
      :error -> Ecto.UUID.generate()
    end

    conn
    |> put_session(:sid, sid)
    |> assign(:sid, sid)
  end

  def ensure_session_id(%Plug.Conn{} = conn, _) do
    sid = get_session(conn, :sid) || Ecto.UUID.generate()

    conn
    |> put_session(:sid, sid)
    |> assign(:sid, sid)
    |> redirect(to: "/?sid=#{sid}")
    |> halt()
  end
end
