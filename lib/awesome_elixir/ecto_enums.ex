defmodule AwesomeElixir.EctoEnums do
  @moduledoc """
  Describes application specific `EctoEnum` types.
  """

  defmodule Accounts.UserRole do
    @moduledoc """
    Using as `role` in `AwesomeElixir.Accounts.User`.

      * :admin
      * :moderator
      * :regular
    """
    use EctoEnum, type: :user_role, enums: [:admin, :moderator, :regular]
  end
end
