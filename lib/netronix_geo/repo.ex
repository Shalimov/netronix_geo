defmodule NetronixGeo.Repo do
  use Ecto.Repo,
    otp_app: :netronix_geo,
    adapter: Ecto.Adapters.Postgres
end
