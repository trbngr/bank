defmodule Bank.Queries.ViewBalance do
  use Cqrs.Query
  alias Bank.{Repo, Core.Accounting.AccountEntry}

  filter :account, :string, required: true

  @impl true
  def handle_create(filters, _opts) do
    query = from e in AccountEntry, select: sum(e.debit) - sum(e.credit)

    Enum.reduce(filters, query, fn
      {:account, account}, query -> from q in query, where: q.account == ^account
    end)
  end

  @impl true
  def handle_execute(query, opts) do
    Repo.one(query, opts)
  end
end
