defmodule Action.LoadFile do
  @moduledoc """
  Example task to show off failing workflows, masquerading as a file loader
  """
  use ETLSystem.Task

  @doc """
  If the arg given to this task is the string "fail" then ... fail.
  Otherwise, return a placeholder value and continue
  """
  def run(%{args: "fail"} = workflow) do
    {:err, :given, workflow}
  end

  def run(workflow) do
    {:ok, "alpha", workflow}
  end
end
