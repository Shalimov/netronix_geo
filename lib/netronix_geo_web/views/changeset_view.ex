defmodule NetronixGeoWeb.ChangesetView do
  use NetronixGeoWeb, :view

  @doc "Transforms changeset error to user readable format"
  def render("error.json", %Ecto.Changeset{} = changeset) do
    %{errors: changeset.errors}
  end
end
