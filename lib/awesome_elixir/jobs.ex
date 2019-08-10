defmodule AwesomeElixir.Jobs do
  import Rihanna
  alias AwesomeElixir.Jobs.{UpdateIndex, UpdateItem}

  def clear_scheduled do
    delete_by(mod: UpdateIndex, arg: [])
  end

  def clear_scheduled(item_id) do
    delete_by(mod: UpdateItem, arg: [item_id])
  end

  def schedule_update do
    schedule(UpdateIndex, [], at: Timex.now() |> Timex.shift(days: 1))
  end

  def schedule_update(item_id) do
    schedule(UpdateItem, [item_id], at: Timex.now() |> Timex.shift(days: 1))
  end

  def schedule_update_in(seconds) do
    schedule(UpdateIndex, [], in: :timer.seconds(seconds))
  end

  def retry_item_in(item_id, seconds) do
    schedule(UpdateItem, [item_id], in: :timer.seconds(seconds))
  end

  def retry_item_at(item_id, at) do
    schedule(UpdateItem, [item_id], at: at)
  end
end
