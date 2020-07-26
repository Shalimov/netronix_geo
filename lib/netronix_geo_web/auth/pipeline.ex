defmodule NetronixGeoWeb.AuthPipeline do
  @moduledoc """
  Pipeline plug implementation to prevent requests without auth token
  """

  use Guardian.Plug.Pipeline,
    otp_app: :netronix_geo,
    module: NetronixGeoWeb.Auth.Guardian,
    error_handler: NetronixGeoWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource
end
