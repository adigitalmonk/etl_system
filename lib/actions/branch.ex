defmodule Action.Branch do
  use ETLSystem.Task

  @moduledoc false
  def run(%{previous: "test", next: next} = workflow) do
    {:ok, nil, ETLSystem.Workflow.next(workflow, [Action.LoadFile | next])}
  end

  def run(workflow) do
    {:ok, nil, workflow}
  end
end
