defmodule Bank.Protocol.DepositMoney do
  use Cqrs.Command
  alias Bank.Core.Application

  field :account_id, :string
  field :amount, :integer

  derive_event AccountOpened, drop: [:amount]
  derive_event MoneyDeposited

  @impl true
  def handle_validate(command, _opts) do
    Ecto.Changeset.validate_number(command, :amount, greater_than: 0)
  end

  @impl true
  def handle_dispatch(command, opts) do
    Application.dispatch(command, opts)
  end
end
