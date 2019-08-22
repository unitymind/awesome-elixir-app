defmodule AwesomeElixir.Accounts.RandomGithubTokenAgent do
  @moduledoc """
  Simple `Agent` for holding current Github access token and random changing them after given usage threshold.
  """

  use Agent
  alias AwesomeElixir.Accounts

  defmodule State do
    @moduledoc """
    Internal `TypedStruct` for holding `State` fields.

        field :usage_threshold, non_neg_integer()
        field :current_usage, non_neg_integer()
        field :token, String.t()
    """

    use TypedStruct

    typedstruct do
      field :usage_threshold, non_neg_integer(), enforce: true
      field :current_usage, non_neg_integer(), enforce: true
      field :token, String.t()
    end
  end

  @doc """
  Starts an `AwesomeElixir.Accounts.RandomTokenAgent` linked to the current process with the given `usage_threshold`.

  This is often used to start the agent as part of a supervision tree.
  """
  @spec start_link(pos_integer()) :: Agent.on_start()
  def start_link(usage_threshold) do
    Agent.start_link(
      fn ->
        %State{
          usage_threshold: usage_threshold,
          current_usage: 0,
          token: Accounts.get_random_github_token()
        }
      end,
      name: __MODULE__
    )
  end

  @spec get() :: nil | String.t()
  def get do
    case state() do
      %{token: nil} ->
        token = Accounts.get_random_github_token()
        :ok = Agent.update(__MODULE__, fn state -> %{state | token: token, current_usage: 1} end)
        token

      %{current_usage: current_usage, usage_threshold: usage_threshold}
      when current_usage == usage_threshold ->
        token = Accounts.get_random_github_token()
        :ok = Agent.update(__MODULE__, fn state -> %{state | token: token, current_usage: 1} end)
        token

      %{token: token} ->
        :ok =
          Agent.update(__MODULE__, fn %{current_usage: current_usage} = state ->
            %{state | current_usage: current_usage + 1}
          end)

        token
    end
  end

  @spec invalidate() :: :ok
  def invalidate, do: invalidate(state().token)

  @spec invalidate(String.t()) :: :ok
  def invalidate(token) do
    case state() do
      %{token: ^token} ->
        Accounts.invalidate_github_token(token)

        Agent.update(__MODULE__, fn state ->
          %{state | current_usage: 0, token: Accounts.get_random_github_token()}
        end)

      _ ->
        Accounts.invalidate_github_token(token)
        :ok
    end
  end

  @spec state() :: State.t()
  def state do
    Agent.get(__MODULE__, & &1)
  end
end
