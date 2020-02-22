defmodule ETLSystem.Scheduler do
  @moduledoc false
  use GenServer

  def start_link({workflow_id, _} = schedule_info) do
    GenServer.start_link(__MODULE__, schedule_info, name: get_name(workflow_id))
  end

  defp get_name(workflow_id) do
    {:via, Registry, {ETLSystem.Scheduler.Registry, workflow_id}}
  end

  @impl true
  def init({_, schedule} = schedule_info) do
    schedule_next(schedule)
    {:ok, schedule_info}
  end

  def schedule_next("minute") do
    Process.send_after(self(), :tick, 60_000)
  end

  def schedule_next("second") do
    Process.send_after(self(), :tick, 1_000)
  end

  @impl true
  def handle_info(:tick, {workflow_id, schedule} = state) do
    # Telemetry: Starting Schedule { workflow_id, current_time}
    ETLSystem.Orchestrator.run_workflow(workflow_id)
    schedule_next(schedule)
    {:noreply, state}
  end
end
