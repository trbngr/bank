defmodule Bank.Core.Accounts.Account do
  alias Bank.Protocol.{DepositMoney, MoneyDeposited, AccountOpened}
  alias Bank.Protocol.{FailMoneyTransfer, MoneyTransferFailed}
  alias Bank.Protocol.{WithdrawMoney, MoneyWithdrawn}
  alias Bank.Protocol.{SendMoneyToAccount, MoneySentToAccount}

  alias Bank.Protocol.{
    ReceiveMoneyFromAccount,
    MoneyReceivedFromAccount,
    MoneyReceivedFromAccountFailed
  }

  alias Bank.Protocol.{JournalEntryCreated}

  alias Bank.Core.Accounts.Account

  @type t() :: %__MODULE__{id: binary(), balance: integer()}
  defstruct [:id, balance: 0]

  def execute(%Account{}, %DepositMoney{account_id: "000-000"}),
    do: {:error, :unable_to_create_account}

  def execute(%Account{id: nil}, %DepositMoney{} = cmd) do
    [
      AccountOpened.new(cmd),
      MoneyDeposited.new(cmd),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: cmd.account_id, amount: cmd.amount}],
        credit: [%{account_id: "000-000", amount: cmd.amount}]
      )
    ]
  end

  def execute(%Account{id: nil}, %ReceiveMoneyFromAccount{} = cmd) do
    MoneyReceivedFromAccountFailed.new(cmd)
  end

  def execute(%Account{id: nil}, _cmd),
    do: {:error, :not_found}

  def execute(%Account{}, %DepositMoney{} = cmd) do
    [
      MoneyDeposited.new(cmd),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: cmd.account_id, amount: cmd.amount}],
        credit: [%{account_id: "000-000", amount: cmd.amount}]
      )
    ]
  end

  def execute(%Account{}, %WithdrawMoney{} = cmd) do
    [
      MoneyWithdrawn.new(cmd),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: cmd.account_id, amount: cmd.amount}],
        credit: [%{account_id: "000-000", amount: cmd.amount}]
      )
    ]
  end

  def execute(%Account{id: id}, %ReceiveMoneyFromAccount{} = cmd) do
    [
      MoneyReceivedFromAccount.new(cmd, to_account_id: id),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: cmd.to_account_id, amount: cmd.amount}],
        credit: [%{account_id: cmd.transaction_id, amount: cmd.amount}]
      )
    ]
  end

  def execute(%Account{id: id}, %FailMoneyTransfer{} = cmd) do
    [
      MoneyTransferFailed.new(cmd, from_account_id: id),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: id, amount: cmd.amount}],
        credit: [%{account_id: cmd.transaction_id, amount: cmd.amount}]
      )
    ]
  end

  def execute(%Account{balance: balance}, %SendMoneyToAccount{amount: amount})
      when balance < amount do
    {:error, :insufficient_balance}
  end

  def execute(%Account{id: id}, %SendMoneyToAccount{} = cmd) do
    transaction_id = Ecto.UUID.generate()

    [
      MoneySentToAccount.new(cmd, transaction_id: transaction_id, from_account_id: id),
      JournalEntryCreated.new!(
        journal_entry_uuid: Ecto.UUID.generate(),
        debit: [%{account_id: transaction_id, amount: cmd.amount}],
        credit: [%{account_id: id, amount: cmd.amount}]
      )
    ]
  end

  def apply(state, %MoneySentToAccount{} = evt) do
    %{state | balance: state.balance - evt.amount}
  end

  def apply(state, %MoneyTransferFailed{} = evt) do
    %{state | balance: state.balance + evt.amount}
  end

  def apply(state, %MoneyReceivedFromAccount{} = evt) do
    %{state | balance: state.balance + evt.amount}
  end

  def apply(state, %AccountOpened{} = evt) do
    %{state | id: evt.account_id}
  end

  def apply(state, %MoneyDeposited{} = evt) do
    %{state | balance: state.balance + evt.amount}
  end

  def apply(state, %MoneyWithdrawn{} = evt) do
    %{state | balance: state.balance - evt.amount}
  end

  def apply(state, %JournalEntryCreated{}), do: state

  def apply(state, %MoneyReceivedFromAccountFailed{}), do: state
end
