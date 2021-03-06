defmodule NetronixGeoWeb.ErrorViewTest do
  use NetronixGeoWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.json" do
    assert render(NetronixGeoWeb.ErrorView, "400.json", %{message: "Bad requesto"}) == %{
             errors: %{detail: "Bad requesto"}
           }
  end

  test "renders 404.json" do
    assert render(NetronixGeoWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(NetronixGeoWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
