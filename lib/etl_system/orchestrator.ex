defmodule ETLSystem.Orchestrator do
  @moduledoc false
  use GenServer
  alias ETLSystem.Action.Supervisor, as: ActionSupervisor
  alias ETLSystem.Scheduler.DynamicSupervisor, as: SchedulerSupervisor
  alias ETLSystem.Workflow

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_) do
    workflows = Application.get_env(:etl_system, ETLSystem.Workflows)

    workflows
    |> Enum.each(fn workflow ->
      with schedule when schedule != nil <- Keyword.get(workflow, :schedule),
           workflow_id when workflow_id != nil <- Keyword.get(workflow, :id) do
        SchedulerSupervisor.start_schedule(workflow_id, schedule)
      end
    end)

    {:ok, workflows}
  end

  def run_workflow(workflow_id) do
    GenServer.cast(__MODULE__, {:run, workflow_id})
  end

  def run_task(%Workflow{next: [{next, args} | rest]} = workflow) do
    workflow =
      workflow
      |> Map.put(:args, args)
      |> Map.put(:next, rest)

    Task.Supervisor.start_child(ActionSupervisor, next, :process, [workflow])
  end

  def run_task(%Workflow{next: [next | rest]} = workflow) do
    workflow =
      workflow
      |> Map.put(:args, nil)
      |> Map.put(:next, rest)

    Task.Supervisor.start_child(ActionSupervisor, next, :process, [workflow])
  end

  def run_task(%Workflow{next: []} = workflow) do
    # Telemetry: Workflow Complete { workflow_id, final_value, timestamp }
    IO.puts("End of the line!")
    IO.inspect(workflow, label: "Done")
  end

  def receive({:ok, result, workflow}) do
    workflow
    |> Workflow.previous(result)
    |> run_task()
  end

  def receive({:err, reason, _workflow}) do
    # Telemetry: Workflow Failure { workflow_id, final_value, timestamp, workflow }
    IO.puts("Something broke! [#{reason}]")
  end

  @impl true
  def handle_cast({:run, workflow_id}, workflows) do
    workflow =
      workflows
      |> Enum.find(fn workflow ->
        Keyword.get(workflow, :id) == workflow_id
      end)

    Keyword.get(workflow, :steps)
    |> ETLSystem.Workflow.new(workflow_id)
    |> __MODULE__.run_task()

    {:noreply, workflows}
  end
end
