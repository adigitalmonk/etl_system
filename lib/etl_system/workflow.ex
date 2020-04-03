defmodule ETLSystem.Workflow do
  @moduledoc """
  Contains the necessary information to define a workflow
  """

  @typedoc """
  Defines the structure of a workflow.
  """
  @type t :: %__MODULE__{id: binary(), next: list(), args: any(), previous: any(), run_id: term()}

  defstruct [:id, :next, :args, :previous, :run_id]

  @doc """
  Create a new workflow with:
  - The workflow steps and params
  - The name of the workflow defined in the config
  - A unique identifier for the run itself for logging purposes
  """
  def new(workflow_steps, id, run_id),
    do: %__MODULE__{id: id, next: workflow_steps, run_id: run_id}

  @doc """
  Update :previous with a given value.

  This is used by the runner to store the result of a task for the next task to receive
  """
  def previous(workflow, previous), do: %__MODULE__{workflow | previous: previous}

  @doc """
  Update a running workflow's next steps.

  This is used by a task that wants to change the future tasks in the workflow.
  """
  def next(workflow, next), do: %__MODULE__{workflow | next: next}
end
