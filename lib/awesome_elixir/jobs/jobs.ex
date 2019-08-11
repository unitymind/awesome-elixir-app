defmodule AwesomeElixir.Jobs do
  import Rihanna
  alias AwesomeElixir.Jobs.{UpdateIndex, UpdateItem}

  @spec clear_scheduled() :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled do
    delete_by(mod: UpdateIndex, arg: [])
  end

  @spec clear_scheduled(integer()) :: {:ok, :deleted} | {:error, :job_not_found}
  def clear_scheduled(item_id) when is_integer(item_id) do
    delete_by(mod: UpdateItem, arg: [item_id])
  end

  @spec schedule_update() :: {:ok, Rihanna.Job.t()}
  def schedule_update do
    schedule(UpdateIndex, [], at: Timex.now() |> Timex.shift(days: 1))
  end

  @spec schedule_update(integer()) :: {:ok, Rihanna.Job.t()}
  def schedule_update(item_id) when is_integer(item_id) do
    schedule(UpdateItem, [item_id], at: Timex.now() |> Timex.shift(days: 1))
  end

  @spec schedule_update_in(integer()) :: {:ok, Rihanna.Job.t()}
  def schedule_update_in(seconds) when is_integer(seconds) do
    schedule(UpdateIndex, [], in: :timer.seconds(seconds))
  end

  @spec retry_item_in(integer(), integer()) :: {:ok, Rihanna.Job.t()}
  def retry_item_in(item_id, seconds) when is_integer(item_id) and is_integer(seconds) do
    schedule(UpdateItem, [item_id], in: :timer.seconds(seconds))
  end

  @spec retry_item_in(integer(), DateTime.t()) :: {:ok, Rihanna.Job.t()}
  def retry_item_at(item_id, at) when is_integer(item_id) and is_map(at) do
    schedule(UpdateItem, [item_id], at: at)
  end
end
