defmodule Action.LoadFile do
  use ETLSystem.Task

  @moduledoc false
  def run(%{args: "fail"}) do
    {:err, :given}
  end

  def run(workflow) do
    {:ok, "alpha", workflow}
  end
end
