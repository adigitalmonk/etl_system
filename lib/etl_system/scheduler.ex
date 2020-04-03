defmodule ETLSystem.Scheduler do
  @moduledoc false
  use GenServer
  alias ETLSystem.Scheduler.State

  @doc false
  def start_link({workflow_id, _} = schedule_info) do
    GenServer.start_link(__MODULE__, schedule_info, name: get_name(workflow_id))
  end

  defp get_name(workflow_id) do
    {:via, Registry, {ETLSystem.Scheduler.Registry, workflow_id}}
  end

  @doc """
  Take a workflow_id and schedule, then set up the state of the object for it.
  Creating the state also starts the server tick based on the period defined by the schedule.
  """
  @impl true
  def init({workflow_id, schedule}) do
    {:ok, State.new(workflow_id, schedule)}
  end

  @doc """
  Server ticks mean it's time to kick off a schedule.

  Theoretically, jobs with no schedule could still get a schedule item created
  and the scheduler receiving a manual :tick could kick off the workflow instead
  of relying on calling to the orchestrator to start it manually.
  """
  @impl true
  def handle_info(:tick, state), do: {:noreply, State.start(state)}
end
