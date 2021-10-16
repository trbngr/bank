defmodule Bank.Protocol.CreateLoan do
  use Cqrs.Command
  alias Bank.Core.Application

  field :loan_id, :string
  field :account_id, :string
  field :amount, :integer
  field :loan_fee, :integer

  @impl true
  def handle_dispatch(command, opts) do
    Application.dispatch(command, opts)
  end
end
