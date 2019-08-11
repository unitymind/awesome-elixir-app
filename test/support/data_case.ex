defmodule AwesomeElixir.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias AwesomeElixir.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import AwesomeElixir.DataCase
      import AwesomeElixir.Factory
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AwesomeElixir.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AwesomeElixir.Repo, {:shared, self()})
    end

    with {:ok, _} <- HTTPoison.start(), do: :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def assert_insert_cant_be_blank(entity, fields, insert_func) do
    for field <- fields, value <- [nil, ""] do
      {:error, changeset} = entity |> Map.put(field, value) |> insert_func.()
      assert "can't be blank" in (errors_on(changeset) |> Map.get(field, []))
    end
  end

  def assert_update_cant_be_blank(entity, fields, update_func) do
    for field <- fields, value <- [nil, ""] do
      {:error, changeset} = entity |> update_func.(Map.put(%{}, field, value))
      assert "can't be blank" in (errors_on(changeset) |> Map.get(field, []))
    end
  end
end
