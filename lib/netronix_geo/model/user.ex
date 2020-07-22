defmodule NetronixGeo.Model.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias NetronixGeo.Model

  schema "users" do
    field :email, :string, size: 255
    field :password, :string

    many_to_many :roles, Model.Role, join_through: "user_roles"
    has_many :created_tasks, Model.Task, foreign_key: :creator_id
    has_many :assigned_tasks, Model.Task, foreign_key: :assignee_id
    has_one :token, Model.Token

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> put_assoc(:roles, attrs.roles)
    |> validate_required([:email, :password])
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
