defmodule Bank.Protocol.WithdrawMoney do
  use Cqrs.Command
  alias Bank.Core.Application

  field :account_id, :string
  field :amount, :integer

  derive_event MoneyWithdrawn

  @impl true
  def handle_dispatch(command, opts) do
    Application.dispatch(command, opts)
  end
end
