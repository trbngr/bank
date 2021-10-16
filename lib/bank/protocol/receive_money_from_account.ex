defmodule Bank.Protocol.ReceiveMoneyFromAccount do
  use Cqrs.Command
  alias Bank.Core.Application

  field :transaction_id, :string
  field :from_account_id, :string
  field :to_account_id, :string
  field :amount, :integer

  derive_event MoneyReceivedFromAccount
  derive_event MoneyReceivedFromAccountFailed

  @impl true
  def handle_dispatch(command, opts) do
    Application.dispatch(command, opts)
  end
end
