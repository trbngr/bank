defmodule Bank.AggregateCase do
  use ExUnit.CaseTemplate

  using aggregate: aggregate do
    quote do
      @aggregate unquote(aggregate)
      import Bank.AggregateCase, only: :macros
    end
  end

  defmacro assert_events(initial_events \\ [], command, expected_events) do
    quote do
      {actual_events, error, state} =
        Bank.AggregateCase.execute(@aggregate, unquote(initial_events), unquote(command))

      assert nil == error

      assert Enum.map(List.wrap(unquote(expected_events)), &Map.delete(&1, :created_at)) ==
               Enum.map(actual_events, &Map.delete(&1, :created_at))

      state
    end
  end

  defmacro execute_command(initial_events \\ [], command) do
    quote do
      {actual_events, error, state} =
        Bank.AggregateCase.execute(@aggregate, unquote(initial_events), unquote(command))

      {actual_events, error, state}
    end
  end

  defmacro assert_error(initial_events \\ [], command, expected_error) do
    quote do
      {_actual_events, acutal_error, state} =
        Bank.AggregateCase.execute(@aggregate, unquote(initial_events), unquote(command))

      assert unquote(expected_error) == acutal_error
      state
    end
  end

  def execute(aggregate, initial_events, command) do
    state = Bank.AggregateCase.evolve(aggregate, struct(aggregate), initial_events)

    case aggregate.execute(state, command) do
      {:error, _reason} = error -> {nil, error, state}
      events -> {events, nil, evolve(aggregate, state, events)}
    end
  end

  def evolve(aggregate, state, events) do
    events
    |> List.wrap()
    |> Enum.reduce(state, &aggregate.apply(&2, &1))
  end
end
