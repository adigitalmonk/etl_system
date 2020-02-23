defmodule Action.MangleData do
  use ETLSystem.Task

  @moduledoc false
  def run(workflow) do
    {:ok, "beta", workflow}
  end
end
