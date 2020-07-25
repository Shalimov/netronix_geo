defmodule NetronixGeoWeb.FallbackController do
  use NetronixGeoWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(NetronixGeoWeb.ChangesetView)
    |> render("error.json", changeset)
  end

  def call(conn, {:error, {:bad_request, message}}) do
    conn
    |> put_status(:bad_request)
    |> put_view(NetronixGeoWeb.ErrorView)
    |> render("400.json", %{message: message})
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:bad_request)
    |> put_view(NetronixGeoWeb.ErrorView)
    |> render("401.json")
  end
end
