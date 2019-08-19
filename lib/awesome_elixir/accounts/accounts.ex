defmodule AwesomeElixir.Accounts do
  alias AwesomeElixir.Accounts.User
  alias AwesomeElixir.Repo

  def get_user_by_id(id), do: Repo.get(User, id)

  def find_or_create_from_auth(%Ueberauth.Auth{} = auth) do
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
