defmodule NetronixGeoWeb.Auth.ErrorHandler do
  @moduledoc false

  import Phoenix.Controller

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_view(NetronixGeoWeb.ErrorView)
    |> render("401.json", %{message: to_string(type)})
  end
end
