defmodule NetronixGeo.Postgres.PGPoint do
  use Ecto.Type

  alias Postgrex.Point

  def type, do: Point

  # Casting from input into point struct
  def cast(%Point{} = value), do: {:ok, value}
  def cast({lng, lat}), do: {:ok, %Point{x: lng, y: lat}}
  def cast(_), do: :error

  # loading data from the database
  def load(data) do
    {:ok, data}
  end

  # dumping data to the database
  def dump(%Point{} = value), do: {:ok, value}
  def dump(_), do: :error

  defmodule Operators do
    # Similart to Postgre <-> operator to use in the same way
    # For kNN search
    defmacro p1 <~> p2 do
      quote do
        fragment("? <-> ?", unquote(p1), unquote(p2))
      end
    end
  end
end
