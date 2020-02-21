defmodule ETLSystem.Workflow do
  @moduledoc false
  defstruct [:next, :args, :previous]

  def new(workflow), do: %__MODULE__{next: workflow}

  def previous(workflow, previous), do: %__MODULE__{workflow | previous: previous}
  def next(workflow, next), do: %__MODULE__{workflow | next: next}
end
