defmodule Action.LoadFile do
  use ETLSystem.Task

  @moduledoc false
  def run(%{args: "fail"} = workflow) do
    {:err, :given, workflow}
  end

  def run(workflow) do
    {:ok, "alpha", workflow}
  end
end
