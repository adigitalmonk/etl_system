defmodule Examples.Branch do
  @moduledoc """
  Example branching task
  """
  use ETLSystem.Task

  @doc """
  If the previous result was "test", inject the LoadFile task as the next step
  Otherwise, just continue on with the next steps.
  """
  def run(%{previous: "count"} = workflow) do
    {:ok, nil, next_steps(workflow, [Example.Counter | workflow.next])}
  end

  def run(workflow) do
    {:ok, nil, workflow}
  end
end
