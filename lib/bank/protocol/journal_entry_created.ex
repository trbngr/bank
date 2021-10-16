defmodule Bank.Protocol.JournalEntryCreated do
  use Cqrs.ValueObject
  alias Bank.Protocol.AccountEntry

  field :journal_entry_uuid, :string
  field :debit, {:array, AccountEntry}
  field :credit, {:array, AccountEntry}
end
