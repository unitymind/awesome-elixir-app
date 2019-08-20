defmodule AwesomeElixir.Repo do
  @moduledoc """
  Just a application specific proxy module to `Ecto.Repo`.
  """
  use Ecto.Repo,
    otp_app: :awesome_elixir,
    adapter: Ecto.Adapters.Postgres
end
