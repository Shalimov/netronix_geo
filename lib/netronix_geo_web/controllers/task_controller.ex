defmodule NetronixGeoWeb.TaskController do
  use NetronixGeoWeb, :controller

  @doc "Returns serialized JSON name"
  @spec name(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def name(conn, %{"name" => name}) do
    json(conn, %{harbindger: "Welcome Back MR: #{name}"})
  end
end
