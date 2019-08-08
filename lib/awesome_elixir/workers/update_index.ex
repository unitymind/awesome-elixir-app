defmodule AwesomeElixir.Workers.UpdateIndex do
  alias AwesomeElixir.Scraper

  def perform do
    clear_scheduled()
    Scraper.update_index()
    schedule_update()
  end

  defp schedule_update do
    Exq.enqueue_at(
      Exq,
      "default",
      Timex.now() |> Timex.shift(days: 1),
      AwesomeElixir.Workers.UpdateIndex,
      []
    )
  end

  defp clear_scheduled do
    case Exq.Api.scheduled(Exq.Api) do
      {:ok, jobs} ->
        Enum.filter(jobs, fn job -> job.class == "AwesomeElixir.Workers.UpdateIndex" end)
        |> Enum.each(fn %Exq.Support.Job{jid: jid} -> Exq.Api.remove_scheduled(Exq.Api, jid) end)
    end
  end
end
