defmodule Examples.FailTask do
  @moduledoc """
  Example task to show off failing workflows
  """
  use ETLSystem.Task

  @doc """
  If the arg given to this task is the string "fail" then ... fail.
  Otherwise, return the value of the previous step.
  """
  def run(%{args: "fail"} = workflow) do
    {:err, :given, workflow}
  end

  def run(workflow) do
    {:ok, workflow.previous, workflow}
  end
end
