defmodule ETLSystem.Workflow do
  @moduledoc false

  @type t :: %__MODULE__{next: list(), args: any(), previous: any()}

  defstruct [:id, :next, :args, :previous, :run_id]

  def new(workflow), do: %__MODULE__{next: workflow}
  def new(workflow, id, run_id), do: %__MODULE__{id: id, next: workflow, run_id: run_id}

  def previous(workflow, previous), do: %__MODULE__{workflow | previous: previous}
  def next(workflow, next), do: %__MODULE__{workflow | next: next}
end
