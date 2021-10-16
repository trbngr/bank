defmodule Bank.Core.Accounts.MoneyTransferProcessManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "Bank.Core.Accounts.MoneyTransferProcessManager",
    start_from: :origin,
    application: Bank.Core.Application

  alias Bank.Protocol.{FailMoneyTransfer, MoneyTransferFailed, ReceiveMoneyFromAccount}

  alias Bank.Protocol.{
    MoneySentToAccount,
    MoneyReceivedFromAccount,
    MoneyReceivedFromAccountFailed
  }

  defstruct [:transaction_id]

  def interested?(%MoneySentToAccount{transaction_id: id}), do: {:start, id}
  def interested?(%MoneyReceivedFromAccountFailed{transaction_id: id}), do: {:continue, id}
  def interested?(%MoneyReceivedFromAccount{transaction_id: id}), do: {:stop, id}
  def interested?(%MoneyTransferFailed{transaction_id: id}), do: {:stop, id}

  def handle(%__MODULE__{}, %MoneySentToAccount{} = evt),
    do: [
      %ReceiveMoneyFromAccount{
        transaction_id: evt.transaction_id,
        from_account_id: evt.from_account_id,
        to_account_id: evt.to_account_id,
        amount: evt.amount
      }
    ]

  def handle(%__MODULE__{}, %MoneyReceivedFromAccountFailed{} = evt),
    do: [
      %FailMoneyTransfer{
        transaction_id: evt.transaction_id,
        from_account_id: evt.from_account_id,
        to_account_id: evt.to_account_id,
        amount: evt.amount
      }
    ]

  def apply(_state, %MoneySentToAccount{} = evt) do
    %__MODULE__{transaction_id: evt.transaction_id}
  end
end
