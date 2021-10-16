defmodule Bank.Protocol.CreateRawEntry do
  use Cqrs.Command
  alias Bank.Protocol.{AccountEntry, JournalEntryCreated}

  field :debit, {:array, AccountEntry}
  field :credit, {:array, AccountEntry}

  @impl true
  def handle_dispatch(%{credit: credit, debit: debit}, _opts) do
    Bank.Core.EventStore.append_to_stream("raw_entries", :any_version, [
      %EventStore.EventData{
        event_id: Ecto.UUID.generate(),
        event_type: "#{JournalEntryCreated}",
        causation_id: Ecto.UUID.generate(),
        correlation_id: Ecto.UUID.generate(),
        data: %JournalEntryCreated{
          journal_entry_uuid: Ecto.UUID.generate(),
          debit: debit,
          credit: credit
        }
      }
    ])
  end
end
