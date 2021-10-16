defmodule Bank.Protocol.DepositMoneyTest do
  use Bank.DataCase
  use Bank.AggregateCase, aggregate: Bank.Core.Accounts.Account
  use Bank.CommandedCase

  doctest Bank.Protocol.DepositMoney
  alias Bank.Protocol.{DepositMoney, AccountOpened, MoneyDeposited, JournalEntryCreated}

  describe "validation" do
    test "account_id and amount are required" do
      assert {:error, %{account_id: ["can't be blank"], amount: ["can't be blank"]}} =
               DepositMoney.new()
    end

    test "amount must be greater than zero" do
      assert {:error, %{amount: ["must be greater than 0"]}} =
               DepositMoney.new(account_id: "123", amount: 0)
    end
  end

  describe "aggregate execution" do
    test "account 000-000 is reserved" do
      {:ok, command} = DepositMoney.new(account_id: "000-000", amount: 500)
      assert_error(command, {:error, :unable_to_create_account})
    end

    test "raises events and updates state" do
      account_id = "000-001"
      amount = 500

      {:ok, command} = DepositMoney.new(account_id: account_id, amount: amount)

      assert {events, _error, state} = execute_command(command)

      assert %{balance: ^amount, id: ^account_id} = state

      assert [
               %AccountOpened{account_id: ^account_id},
               %MoneyDeposited{account_id: ^account_id, amount: ^amount},
               %JournalEntryCreated{
                 debit: [%{account_id: ^account_id, amount: ^amount}],
                 credit: [%{account_id: "000-000", amount: ^amount}]
               }
             ] = events
    end
  end

  describe "command dispatch" do
    alias Bank.Core.{Accounting, Accounts}

    test "from module" do
      account_id = "000-001"
      amount = 500

      assert :ok =
               %{account_id: account_id, amount: amount}
               |> DepositMoney.new()
               |> DepositMoney.dispatch()

      #  This shouldn't be necessary. Not my app, not my problem :)
      Process.sleep(100)

      assert amount == Accounts.view_balance(account: account_id)
      assert amount == Accounting.current_balance(account: account_id)
    end

    test "from context" do
      account_id = "000-001"
      amount = 500

      assert :ok = Accounts.deposit_money(account_id: account_id, amount: amount)

      #  This shouldn't be necessary. Not my app, not my problem :)
      Process.sleep(100)

      assert amount == Accounts.view_balance(account: account_id)
      assert amount == Accounting.current_balance(account: account_id)
    end
  end
end
