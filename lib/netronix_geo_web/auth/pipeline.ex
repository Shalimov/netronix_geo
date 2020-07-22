defmodule NetronixGeoWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :netronix_geo

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource
end
