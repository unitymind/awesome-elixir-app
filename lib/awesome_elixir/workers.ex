defmodule AwesomeElixir.Workers do
  def clear_scheduled do
    case Exq.Api.scheduled(Exq.Api) do
      {:ok, jobs} ->
        Enum.filter(jobs, fn job -> job.class == "AwesomeElixir.Workers.UpdateIndex" end)
        |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end

  def clear_scheduled(item_id) do
    with {:ok, jobs} <- Exq.Api.scheduled(Exq.Api) do
      Enum.filter(jobs, fn job ->
        job.class == "AwesomeElixir.Workers.UpdateItem" && job.args == [item_id]
      end)
      |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end

  def schedule_update do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      AwesomeElixir.Workers.UpdateIndex,
      []
    )
  end

  def schedule_update(item_id) do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      AwesomeElixir.Workers.UpdateItem,
      [item_id]
    )
  end

  def schedule_update_in(seconds) do
    Exq.enqueue_in(
      Exq,
      "default",
      seconds,
      AwesomeElixir.Workers.UpdateIndex,
      []
    )
  end

  def retry_item_in(item_id, seconds) do
    Exq.enqueue_in(
      Exq,
      "default",
      seconds,
      AwesomeElixir.Workers.UpdateItem,
      [item_id]
    )
  end

  def retry_item_at(item_id, at) do
    Exq.enqueue_at(
      Exq,
      "default",
      at,
      AwesomeElixir.Workers.UpdateItem,
      [item_id]
    )
  end
end
