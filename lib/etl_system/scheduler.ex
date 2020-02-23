defmodule ETLSystem.Scheduler do
  @moduledoc false
  use GenServer
  alias ETLSystem.Scheduler.State

  def start_link({workflow_id, _} = schedule_info) do
    GenServer.start_link(__MODULE__, schedule_info, name: get_name(workflow_id))
  end

  defp get_name(workflow_id) do
    {:via, Registry, {ETLSystem.Scheduler.Registry, workflow_id}}
  end

  @impl true
  def init({workflow_id, schedule}) do
    {:ok, State.new(workflow_id, schedule)}
  end

  @impl true
  def handle_info(:tick, state), do: { :noreply, State.start(state) }
end
