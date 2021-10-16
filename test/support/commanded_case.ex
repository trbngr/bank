defmodule Bank.CommandedCase do
  use ExUnit.CaseTemplate

  setup do
    on_exit(fn ->
      :ok = Application.stop(:bank)
      :ok = Application.stop(:commanded)

      {:ok, _apps} = Application.ensure_all_started(:bank)
    end)
  end
end
