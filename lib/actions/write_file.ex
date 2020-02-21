defmodule Action.WriteFile do
  @moduledoc false
  def run(workflow) do
    IO.inspect(workflow, label: "Write File")
    {:ok, "gamma", workflow}
  end
end
