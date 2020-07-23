defimpl Jason.Encoder, for: [Geo.Point] do
  @doc "Jason encoder protocol implementation for external library structure: Geo.Point"
  def encode(%Geo.Point{coordinates: {lng, lat}}, opts) do
    Jason.Encode.list([lng, lat], opts)
  end
end
