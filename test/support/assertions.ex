defmodule AwesomeElixir.Support.Assertions do
  import ExUnit.Assertions
  import AwesomeElixir.Support.Helpers

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

  def assert_is_binary_list(list) when is_list(list) do
    for field <- list, do: assert(is_binary(field))
  end
end
