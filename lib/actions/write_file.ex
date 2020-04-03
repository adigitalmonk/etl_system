defmodule Action.WriteFile do
  @moduledoc """
  Example task to show returning some value and doing nothing else, masquerading as a file writer
  """

  use ETLSystem.Task

  @doc false
  def run(workflow) do
    {:ok, "gamma", workflow}
  end
end
