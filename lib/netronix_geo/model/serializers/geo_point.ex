defimpl Jason.Encoder, for: Postgrex.Point do
  @doc "Jason encoder protocol implementation for external library structure: Geo.Point"
  def encode(%Postgrex.Point{x: lng, y: lat}, opts) do
    Jason.Encode.list([lng, lat], opts)
  end
end
