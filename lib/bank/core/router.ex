defmodule Bank.Core.Router do
  use Commanded.Commands.Router

  alias Bank.Protocol.{
    DepositMoney,
    FailMoneyTransfer,
    WithdrawMoney,
    ReceiveMoneyFromAccount,
    SendMoneyToAccount
  }

  dispatch(
    [
      DepositMoney,
      WithdrawMoney
    ],
    to: Bank.Core.Accounts.Account,
    identity: :account_id
  )

  dispatch(
    [SendMoneyToAccount, FailMoneyTransfer],
    to: Bank.Core.Accounts.Account,
    identity: :from_account_id
  )

  dispatch(
    [ReceiveMoneyFromAccount],
    to: Bank.Core.Accounts.Account,
    identity: :to_account_id
  )
end
