defmodule Bank.Core.Accounts do
  @moduledoc "Core context of user Accounts."

  use Cqrs.BoundedContext

  alias Bank.{Protocol, Queries}

  command Protocol.DepositMoney
  command Protocol.WithdrawMoney
  command Protocol.SendMoneyToAccount

  query Queries.ViewBalance
end
