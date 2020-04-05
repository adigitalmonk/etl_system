defmodule ETLSystem.OrchestratorTest do
  @moduledoc false
  use ExUnit.Case
  alias ETLSystem.Orchestrator
  doctest Orchestrator

  def ids_are_unique(ids \\ MapSet.new(), counter \\ 0)
  def ids_are_unique(_, 100), do: true
  def ids_are_unique(ids, counter) do
    new_id = Orchestrator.generate_run_id()
    case MapSet.member?(ids, new_id) do
      false ->
        ids_are_unique(MapSet.put(ids, new_id), counter + 1)

      true ->
        false
    end
  end

  describe "generate_run_id/0" do
    test "generates lots of unique IDs" do
      assert ids_are_unique()
    end
  end

end
