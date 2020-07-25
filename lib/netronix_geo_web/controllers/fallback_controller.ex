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

  # Workaround
  # Related to bodyguard issues
  # since config overriding isn't working
  # default_error: :forbidden -> doesn't work
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(NetronixGeoWeb.ErrorView)
    |> render("403.json")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(NetronixGeoWeb.ErrorView)
    |> render("404.json")
  end
end
