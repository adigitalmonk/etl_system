defmodule Action.LoadFile do
  @moduledoc false
  def run(%{ args: args } = workflow) do
    if args == "fail" do
      {:err, :given}
    else
      IO.inspect(workflow, label: "Load File")
      {:ok, "alpha", workflow}
    end
  end
end
