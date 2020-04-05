defmodule Examples.Counter do
  @moduledoc """
  Example task that updates the next steps to simulate counting
  """
  use ETLSystem.Task

  @doc """
  For a given step, if the previous result hasn't reached the target value yet,
  inject this module back into the workflow and increment the return value
  based on the value of the previous result
  """
  def run(%{previous: nil, args: target} = workflow) do
    Process.sleep(500)
    {:ok, 1, next_up(workflow, __MODULE__, target)}
  end

  def run(%{previous: previous, args: target} = workflow) when previous >= target do
    {:ok, previous, workflow}
  end

  def run(%{previous: previous, args: target} = workflow) do
    Process.sleep(500)
    {:ok, previous + 1, next_up(workflow, __MODULE__, target)}
  end
end
