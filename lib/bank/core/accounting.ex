defmodule Bank.Core.Accounting do
  @moduledoc "Accounting context."

  use Cqrs.BoundedContext

  alias Bank.{Protocol, Queries}

  command Protocol.CreateRawEntry
  command Protocol.ValidateEvent

  query Queries.ViewBalance, as: :current_balance
end
