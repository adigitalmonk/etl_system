defmodule ETLSystem.Task do
  @moduledoc false

  @callback run(ETLSystem.Workflow.t()) ::
              {
                :ok,
                term(),
                ETLSystem.Workflow.t()
              }
              | {:err, :error, ETLSystem.Workflow.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour ETLSystem.Task
      use Task

      def process(workflow) do
        :telemetry.execute(
          [:etl, :run, :action],
          %{
            workflow_id: workflow.id,
            timestamp: DateTime.utc_now(),
            action: __MODULE__,
          },
          workflow
        )

        run(workflow)
        |> ETLSystem.Orchestrator.receive()
      end
    end
  end
end
