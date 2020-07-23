defimpl Jason.Encoder, for: [NetronixGeo.Model.Role] do
  @doc "Jason encoder protocol implementation for Ecto.Model of Role"
  def encode(struct, opts) do
    Enum.reduce(Map.from_struct(struct), %{}, fn
      {_key, %Ecto.Association.NotLoaded{}}, acc -> acc
      {key, _}, acc when key in [:__meta__, :__struct__] -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
    |> Jason.Encode.map(opts)
  end
end
