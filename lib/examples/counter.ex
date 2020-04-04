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
  def run(%{previous: nil, args: target, next: next} = workflow) do
    Process.sleep(500)
    {:ok, 1, next_steps(workflow, [{__MODULE__, target} | next])}
  end

  def run(%{previous: previous, args: target, next: next} = workflow) when previous >= target do
    Process.sleep(500)
    {:ok, previous, next_steps(workflow, next)}
  end

  def run(%{previous: previous, args: target, next: next} = workflow) do
    Process.sleep(500)
    {:ok, previous + 1, next_steps(workflow, [{__MODULE__, target} | next])}
  end
end
