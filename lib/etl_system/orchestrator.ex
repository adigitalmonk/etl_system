defmodule ETLSystem.Orchestrator do
  @moduledoc false
  use GenServer
  alias ETLSystem.Action.DynamicSupervisor, as: ActionSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Application.get_env(:etl_system, ETLSystem.Tasks)
    |> Enum.each(fn task ->
      ActionSupervisor.start_task(task)
    end)

    workflows = Application.get_env(:etl_system, ETLSystem.Workflows)

    {:ok, workflows}
  end

  def run_workflow(workflow_id) do
    GenServer.cast(__MODULE__, {:run, workflow_id})
  end

  @impl true
  def handle_cast({:run, workflow_id}, workflows) do
    workflow =
      workflows
      |> Enum.find(fn workflow ->
        Keyword.get(workflow, :task_id) == workflow_id
      end)

    Keyword.get(workflow, :steps)
    |> ETLSystem.Action.run()

    {:noreply, workflows}
  end
end
