defimpl Jason.Encoder, for: [NetronixGeo.Model.Task] do
  @doc "Jason encoder protocol implementation for Ecto.Model of Task"
  def encode(struct, opts) do
    Enum.reduce(Map.from_struct(struct), %{}, fn
      {_key, %Ecto.Association.NotLoaded{}}, acc -> acc
      {:__meta__, _value}, acc -> acc
      {:__struct__, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
    |> Jason.Encode.map(opts)
  end
end
