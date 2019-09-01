defmodule AwesomeElixir.Jobs do
  @moduledoc """
  Acts as helper wrapper on `Exq` job scheduling system.
  """

  alias AwesomeElixir.Jobs.{UpdateIndex, UpdateItem}

  @doc """
  Clear all previously scheduled `AwesomeElixir.Jobs.UpdateIndex` jobs.
  """
  #  @spec clear_scheduled() :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled do
    case Exq.Api.scheduled(Exq.Api) do
      {:ok, jobs} ->
        Enum.filter(jobs, fn job -> job.class == "AwesomeElixir.Jobs.UpdateIndex" end)
        |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end

  @doc """
  Clear previously scheduled `AwesomeElixir.Jobs.UpdateItem` job for given `item_id`.
  """
  #  @spec clear_scheduled(integer()) :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled(item_id) when is_integer(item_id) do
    with {:ok, jobs} <- Exq.Api.scheduled(Exq.Api) do
      Enum.filter(jobs, fn job ->
        job.class == "AwesomeElixir.Jobs.UpdateItem" && job.args == [item_id]
      end)
      |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateIndex` job on the next day.
  """
  #  @spec schedule_update() :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      UpdateIndex,
      []
    )
  end

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateItem` job on the next day for given `item_id`.
  """
  #  @spec schedule_update(integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update(item_id) do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      UpdateItem,
      [item_id]
    )
  end

  # coveralls-ignore-start

  @doc """
  Schedule `AwesomeElixir.Jobs.UpdateIndex` job within given `seconds`.
  """
  #  @spec schedule_update_in(integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def schedule_update_in(seconds) do
    Exq.enqueue_in(
      Exq,
      "default",
      seconds,
      UpdateIndex,
      []
    )
  end

  # coveralls-ignore-stop

  @doc """
  Retry `AwesomeElixir.Jobs.UpdateItem` job for given `item_id` within given `seconds`.
  """
  #  @spec retry_item_in(integer(), integer()) :: {:ok, Rihanna.Job.t()} | no_return()
  def retry_item_in(item_id, seconds) do
    Exq.enqueue_in(
      Exq,
      "default",
      seconds,
      UpdateItem,
      [item_id]
    )
  end

  @doc """
  Retry `AwesomeElixir.Jobs.UpdateItem` job for given `item_id` on concrete `at`.
  """
  #  @spec retry_item_at(integer(), DateTime.t()) :: {:ok, Rihanna.Job.t()} | no_return()
  def retry_item_at(item_id, at) do
    Exq.enqueue_at(
      Exq,
      "default",
      at,
      UpdateItem,
      [item_id]
    )
  end
end
