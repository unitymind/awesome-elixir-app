defmodule AwesomeElixir.Accounts.User do
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "users" do
    field :github_uid, :id
    field :github_token, :string

    embeds_one :profile, Profile, on_replace: :delete, primary_key: false do
      field :name, :string
      field :nickname, :string
      field :email, EctoFields.Email
    end

    timestamps()
  end

  @fields ~w(github_uid github_token)a
  @profile_fields ~w(name nickname email)a

  @doc false
  def changeset(%__MODULE__{} = user, attrs) when is_map(attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> cast_embed(:profile, with: &profile_changeset/2)
  end

  defp profile_changeset(schema, params) do
    schema
    |> cast(params, @profile_fields)
  end
end
