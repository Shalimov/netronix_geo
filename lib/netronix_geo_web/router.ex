defmodule NetronixGeoWeb.Router do
  use NetronixGeoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    if Mix.env() != :test do
      plug NetronixGeoWeb.AuthPipeline
    end
  end

  scope "/api", NetronixGeoWeb do
    pipe_through :api

    post "/tasks", TaskController, :create

    patch "/tasks/:id/assign", TaskController, :assign
    patch "/tasks/:id/complete", TaskController, :complete

    get "/tasks/nearest", TaskController, :list_nearest_tasks
    get "/tasks/:status", TaskController, :list_tasks
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: NetronixGeoWeb.Telemetry
    end
  end
end
