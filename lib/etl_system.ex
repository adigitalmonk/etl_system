defmodule ETLSystem do
  @moduledoc """
  Documentation for `ETLSystem`.
  """
  alias ETLSystem.Orchestrator

  defdelegate run_workflow(workflow_id), to: Orchestrator
end
