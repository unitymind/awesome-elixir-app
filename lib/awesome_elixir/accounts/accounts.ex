defmodule AwesomeElixir.Accounts do
  @moduledoc """
  Acts as context module for accessing to `AwesomeElixir.Accounts.User` entities.
  """

  alias AwesomeElixir.Accounts.User
  alias AwesomeElixir.Repo

  @doc """
  Retrieve `AwesomeElixir.Accounts.User` by `id`
  """
  @spec get_user_by_id(integer() | String.t()) :: User.t() | nil
  def get_user_by_id(id), do: Repo.get(User, id)

  @doc """
  Retrieve or create `AwesomeElixir.Accounts.User` based on `Ueberauth.Auth` data
  """
  @spec find_or_create_user_from_auth(Ueberauth.Auth.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_user_from_auth(%Ueberauth.Auth{} = auth) do
    attrs = extract_attrs_from_auth(auth)

    case Repo.get_by(User, github_uid: attrs.github_uid) do
      nil -> User.changeset(%User{}, attrs) |> Repo.insert()
      user -> User.changeset(user, attrs) |> Repo.update()
    end
  end

  defp extract_attrs_from_auth(auth) do
    %{
      uid: github_uid,
      credentials: %{token: github_token},
      info: %{email: email, name: name, nickname: nickname}
    } = auth

    %{
      github_uid: github_uid,
      github_token: github_token,
      profile: %{email: email, name: name, nickname: nickname}
    }
  end
end
