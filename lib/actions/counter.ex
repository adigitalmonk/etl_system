defmodule Action.Counter do
  use ETLSystem.Task

  @moduledoc false
  def run(%{previous: previous, args: target, next: next} = workflow) when previous == nil do
    # IO.inspect(previous, label: "First")
    Process.sleep(500)
    {:ok, 1, ETLSystem.Workflow.next(workflow, [{__MODULE__, target} | next])}
  end

  def run(%{previous: previous, args: target, next: next} = workflow) when previous >= target do
    # IO.inspect(previous, label: "Second")
    Process.sleep(500)
    {:ok, previous, ETLSystem.Workflow.next(workflow, next)}
  end

  def run(%{previous: previous, args: target, next: next} = workflow) do
    # IO.inspect(previous, label: "Third")
    Process.sleep(500)
    {:ok, previous + 1, ETLSystem.Workflow.next(workflow, [{__MODULE__, target} | next])}
  end
end
