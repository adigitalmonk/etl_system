defmodule Action.Branch do
  @moduledoc false
  def run(%{previous: previous, next: next} = workflow) do
    next =
      if previous == "test" do
        [Action.LoadFile | next]
      else
        next
      end

    {:ok, nil, ETLSystem.Workflow.next(workflow, next)}
  end
end
