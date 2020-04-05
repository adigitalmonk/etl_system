defmodule ETLSystem.Orchestrator do
  @moduledoc false
  use GenServer
  alias ETLSystem.Action.Supervisor, as: ActionSupervisor
  alias ETLSystem.Scheduler.DynamicSupervisor, as: SchedulerSupervisor
  alias ETLSystem.Workflow

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Load all of the workflows into the system.

  For any workflow with a schedule or interval defined,
  start up a scheduler to automatically run it on that schedule.
  """
  @impl true
  def init(_) do
    workflows = Application.get_env(:etl_system, ETLSystem.Workflows) || []

    workflows
    |> Enum.each(fn workflow ->
      with schedule when schedule != nil <- Keyword.get(workflow, :schedule),
           workflow_id when workflow_id != nil <- Keyword.get(workflow, :id) do
        SchedulerSupervisor.start_schedule(workflow_id, {:schedule, schedule})
      end

      with frequency when frequency != nil <- Keyword.get(workflow, :frequency),
           workflow_id when workflow_id != nil <- Keyword.get(workflow, :id) do
        SchedulerSupervisor.start_schedule(workflow_id, {:frequency, frequency})
      end
    end)

    {:ok, workflows}
  end

  @doc """
  Kick off a workflow process.
  """
  def run_workflow(workflow_id) do
    GenServer.cast(__MODULE__, {:run, workflow_id})
  end

  @doc """
  Run a given task in a workflow by pulling it from the list of next steps.
  If there are no :next steps, acknowledge completion.
  """
  def run_task(workflow)

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

  def run_task(%Workflow{next: [], id: id} = workflow) do
    :telemetry.execute(
      [:etl, :run, :finished],
      %{
        workflow_id: id,
        timestamp: DateTime.utc_now()
      },
      workflow
    )
  end

  @doc """
  Handle the result of a task executing.
  If the result's first term is the :err atom, it'll throw a telemetry event and stop execution
  If it's :ok, it'll mark the result into the
  """
  def receive(result)

  def receive({:ok, result, workflow}) do
    workflow
    |> Workflow.previous(result)
    |> run_task()
  end

  def receive({:err, reason, workflow}) do
    :telemetry.execute(
      [:etl, :run, :finished],
      %{
        workflow_id: workflow.id,
        reason: reason,
        timestamp: DateTime.utc_now()
      },
      workflow
    )
  end

  @doc """
  Generate a run ID that will be given to the workflow execution.
  """
  def generate_run_id do
    DateTime.utc_now()
    |> DateTime.to_unix(:microsecond)
  end

  @doc """
  Kick off a workflow for a given workflow_id
  """
  @impl true
  def handle_cast({:run, workflow_id}, workflows) do
    workflow =
      workflows
      |> Enum.find(fn workflow ->
        Keyword.get(workflow, :id) == workflow_id
      end)

    workflow =
      Keyword.get(workflow, :steps)
      |> ETLSystem.Workflow.new(workflow_id, generate_run_id())

    :telemetry.execute(
      [:etl, :run, :started],
      %{
        workflow_id: workflow.id,
        timestamp: DateTime.utc_now()
      },
      workflow
    )

    __MODULE__.run_task(workflow)

    {:noreply, workflows}
  end
end
