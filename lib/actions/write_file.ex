defmodule Action.WriteFile do
  use ETLSystem.Task

  @moduledoc false
  def run(workflow) do
    {:ok, "gamma", workflow}
  end
end
