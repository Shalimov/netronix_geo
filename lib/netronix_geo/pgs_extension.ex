# Extending Postgre with PostGIS types
Postgrex.Types.define(
  NetronixGeo.PGTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions()
)
