defmodule Action.Branch do
  @moduledoc """
  Example branching task
  """
  use ETLSystem.Task

  @doc """
  If the previous result was "test", inject the LoadFile task as the next step
  Otherwise, just continue on with the next steps.
  """
  def run(%{previous: "test", next: next} = workflow) do
    {:ok, nil, next(workflow, [Action.LoadFile | next])}
  end

  def run(workflow) do
    {:ok, nil, workflow}
  end
end
