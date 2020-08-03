Postgrex.Types.define(
  NetronixGeo.PGTypes,
  [Postgrex.Extensions.Point] ++ Ecto.Adapters.Postgres.extensions()
)
