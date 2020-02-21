defmodule Action.MangleData do
  use ETLSystem.Task

  @moduledoc false
  def run(workflow) do
    # IO.inspect(workflow, label: "Mangle Data w/ Arg!")
    {:ok, "beta", workflow}
  end
end
