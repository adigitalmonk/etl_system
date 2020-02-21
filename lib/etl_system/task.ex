defmodule ETLSystem.Task do
  @moduledoc false

  @callback run(ETLSystem.Workflow.t()) :: {:ok, term(), ETLSystem.Workflow.t()} | {:err, :error}

  defmacro __using__(_opts) do
    quote do
      @behaviour ETLSystem.Task
      use Task

      def process(workflow) do
        run(workflow)
        |> ETLSystem.Orchestrator.receive()
      end
    end
  end
end
