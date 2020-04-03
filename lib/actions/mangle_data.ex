defmodule Action.MangleData do
  @moduledoc """
  Example task pretending to make changes to loaded data
  """
  use ETLSystem.Task

  @doc false
  def run(workflow) do
    {:ok, "beta", workflow}
  end
end
