defmodule AwesomeElixir.Jobs do
  @moduledoc """
  Acts as helper wrapper on `Rihanna` job scheduling system.
  """

  import Rihanna
  alias AwesomeElixir.Jobs.{UpdateIndex, UpdateItem}

  @doc """
  Clear all previously scheduled `AwesomeElixir.Jobs.UpdateIndex` jobs.
  """
  @spec clear_scheduled() :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled do
    delete_by(mod: UpdateIndex, arg: [])
  end

  @doc """
  Clear previously scheduled `AwesomeElixir.Jobs.UpdateItem` job for given `item_id`.
  """
  @spec clear_scheduled(integer()) :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled(item_id) when is_integer(item_id) do
    delete_by(mod: UpdateItem, arg: [item_id])
  end

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateIndex` job on the next day.
  """
  @spec schedule_update() :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update do
    schedule(UpdateIndex, [], at: Timex.now() |> Timex.shift(days: 1))
  end

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateItem` job on the next day for given `item_id`.
  """
  @spec schedule_update(integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update(item_id) when is_integer(item_id) do
    schedule(UpdateItem, [item_id], at: Timex.now() |> Timex.shift(days: 1))
  end

  # coveralls-ignore-start

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateIndex` job within given `seconds`.
  """
  @spec schedule_update_in(integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update_in(seconds) when is_integer(seconds) do
    schedule(UpdateIndex, [], in: :timer.seconds(seconds))
  end

  # coveralls-ignore-stop

  @doc """
  Retry `AwesomeElixir.Jobs.UpdateItem` job for given `item_id` within given `seconds`.
  """
  @spec retry_item_in(integer(), integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def retry_item_in(item_id, seconds) when is_integer(item_id) and is_integer(seconds) do
    schedule(UpdateItem, [item_id], in: :timer.seconds(seconds))
  end

  @doc """
  Retry `AwesomeElixir.Jobs.UpdateItem` job for given `item_id` on concrete `at`.
  """
  @spec retry_item_at(integer(), DateTime.t()) :: {:ok, Rihanna.Job.t()} | no_return()
  def retry_item_at(item_id, at) when is_integer(item_id) and is_map(at) do
    schedule(UpdateItem, [item_id], at: at)
  end
end
