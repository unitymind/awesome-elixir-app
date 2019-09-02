defmodule AwesomeElixir.Accounts do
  @moduledoc """
  Acts as context module for accessing to `AwesomeElixir.Accounts.User` entities.
  """

  alias AwesomeElixir.Accounts.User
  alias AwesomeElixir.Repo
  import Ecto.Query
  use Memoize

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
    attrs = extract_attrs_from_auth(auth) |> set_admin_role()

    case Repo.get_by(User, github_uid: attrs.github_uid) do
      nil -> User.changeset(%User{}, attrs) |> Repo.insert()
      user -> User.changeset(user, attrs) |> Repo.update()
    end
  end

  @doc """
  Retrieve github_token from random `AwesomeElixir.Account.User` entity
  """
  @spec get_random_github_token() :: String.t() | nil
  def get_random_github_token do
    query =
      from(
        users in User,
        order_by: fragment("RANDOM()"),
        limit: 1,
        select: [:github_token],
        where: not is_nil(users.github_token)
      )

    case Repo.one(query) do
      %User{github_token: token} -> token
      _ -> nil
    end
  end

  @doc """
  Invalidate given `token` by update according `github_token` value to `nil` in `AwesomeElixir.Repo`
  """
  @spec invalidate_github_token(String.t()) ::
          nil | {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def invalidate_github_token(nil), do: nil

  def invalidate_github_token(token) do
    case Repo.get_by(User, github_token: token) do
      nil -> nil
      user -> User.changeset(user, %{github_token: nil}) |> Repo.update()
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

  defp set_admin_role(attrs) do
    if users_count() == 0 do
      Map.put(attrs, :role, :admin)
    else
      attrs
    end
  end

  defmemop users_count do
    Repo.aggregate(User, :count, :id)
  end
end
