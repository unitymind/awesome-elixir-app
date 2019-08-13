defmodule AwesomeElixir.Support.Assertions do
  import ExUnit.Assertions
  import AwesomeElixir.Support.Helpers

  # coveralls-ignore-start
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

  def refute_list_of_keys(entity, list) when is_map(entity) and is_list(list) do
    for key <- list do
      refute Map.get(entity, key)
    end
  end

  def assert_not_equals_keys(left, right, list)
      when is_map(left) and is_map(right) and is_list(list) do
    for key <- list do
      assert Map.get(left, key) != Map.get(right, key)
    end
  end

  # coveralls-ignore-stop
end
