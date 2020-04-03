defmodule ETLSystem.Task do
  @moduledoc false

  @doc """
  Run this task using the current given state of the workflow.
  Return atom of result, the value to pass to the next task, and any updates to the workflow.
  """
  @callback run(ETLSystem.Workflow.t()) ::
              {:ok, term(), ETLSystem.Workflow.t()}
              | {:err, :error, ETLSystem.Workflow.t()}

  @doc """
  Add the necessary code for turning a module into a Task to be run in a workflow.
  Only requirement is to implement a `run/1` method that accepts an ETLSystem.Workflow struct.
  This requirement is enforced by the behaviour.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      import ETLSystem.Workflow

      @doc false
      def process(workflow) do
        :telemetry.execute(
          [:etl, :run, :action],
          %{
            workflow_id: workflow.id,
            timestamp: DateTime.utc_now(),
            action: __MODULE__
          },
          workflow
        )

        run(workflow)
        |> ETLSystem.Orchestrator.receive()
      end
    end
  end
end
