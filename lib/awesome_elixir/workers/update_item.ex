defmodule AwesomeElixir.Workers.UpdateItem do
  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Scraper

  def perform(item_id) do
    case Repo.get_item_by_id(item_id) do
      %Catalog.Item{} = item ->
        clear_scheduled(item.id)

        case Scraper.Item.update(item) do
          {:retry, :now} ->
            retry_in(item.id, Enum.random(50..70))

          {:ok, %Catalog.Item{}} ->
            schedule_update(item.id)

          {:retry, at} ->
            retry_at(item.id, at)

          _ ->
            nil
        end

      _ ->
        nil
    end
  end

  defp schedule_update(item_id) do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      __MODULE__,
      [item_id]
    )
  end

  defp retry_in(item_id, seconds) do
    Exq.enqueue_in(
      Exq,
      "default",
      seconds,
      __MODULE__,
      [item_id]
    )
  end

  defp retry_at(item_id, at) do
    Exq.enqueue_at(
      Exq,
      "default",
      at,
      __MODULE__,
      [item_id]
    )
  end

  defp clear_scheduled(item_id) do
    case Exq.Api.scheduled(Exq.Api) do
      {:ok, jobs} ->
        Enum.filter(jobs, fn job ->
          job.class == "AwesomeElixir.Workers.UpdateItem" && job.args == [item_id]
        end)
        |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end
end
