defmodule Bank.Protocol.SendMoneyToAccount do
  use Cqrs.Command
  alias Bank.Core.Application

  field :from_account_id, :string
  field :to_account_id, :string
  field :amount, :integer

  derive_event MoneySentToAccount, with: [:transaction_id]

  @impl true
  def handle_dispatch(command, opts) do
    Application.dispatch(command, opts)
  end
end
