defmodule Action.WriteFile do
  use ETLSystem.Task

  @moduledoc false
  def run(workflow) do
    # IO.inspect(workflow, label: "Write File")
    {:ok, "gamma", workflow}
  end
end
