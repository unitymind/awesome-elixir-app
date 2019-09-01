defmodule AwesomeElixirWeb.Policy do
  @behaviour Bodyguard.Policy

  alias AwesomeElixir.Accounts.User

  def authorize(:exq_scope, %User{role: :admin} = _, _), do: true
  def authorize(:exq_scope, _, _), do: false
end
