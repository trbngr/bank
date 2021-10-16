defmodule Bank.Protocol.AccountEntry do
  use Cqrs.ValueObject

  field :account_id, :string
  field :amount, :integer
end
