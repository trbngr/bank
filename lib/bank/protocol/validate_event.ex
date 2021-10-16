defmodule Bank.Protocol.ValidateEvent do
  use Cqrs.Command
  alias Bank.Protocol.JournalEntryCreated

  field :event, JournalEntryCreated

  @impl true
  def handle_dispatch(%{event: %{credit: credit, debit: debit}}, _opts) do
    total_debit = debit |> Enum.map(& &1.amount) |> Enum.sum()
    total_credit = credit |> Enum.map(& &1.amount) |> Enum.sum()

    if total_debit == total_credit,
      do: :ok,
      else: {:error, :bad_entry}
  end
end
