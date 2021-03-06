defmodule AwesomeElixir.Accounts.User do
  @moduledoc """
  Describes `User` entity using `TypedEctoSchema`.

      field :github_uid, :id
      field :github_token, :string
      field :role, UserRole

      embeds_one :profile, Profile, on_replace: :delete, primary_key: false do
        field :name, :string
        field :nickname, :string
        field :email, EctoFields.Email
      end

      timestamps()
  """

  alias AwesomeElixir.EctoEnums.Accounts.UserRole
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "users" do
    field :github_uid, :id
    field :github_token, :string
    field :role, UserRole

    embeds_one :profile, Profile, on_replace: :delete, primary_key: false do
      @moduledoc """
      Embedded schema, holding users's profile details.

          field :name, :string
          field :nickname, :string
          field :email, EctoFields.Email
      """

      field :name, :string
      field :nickname, :string
      field :email, EctoFields.Email
    end

    timestamps()
  end

  @fields ~w(github_uid github_token role)a
  @required_fields ~w(github_uid)a
  @profile_fields ~w(name nickname email)a

  @doc """
  Cast and validate data for insert or update.

    * Allowed: `github_uid`, `github_token`, `role`, `profile`
    * Required: `github_uid`
    * Cast `profile` on embedded schema
  """
  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user, attrs) when is_map(attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:profile, with: &profile_changeset/2)
  end

  defp profile_changeset(schema, params) do
    schema
    |> cast(params, @profile_fields)
  end
end
