defmodule ETLSystem.Scheduler.DynamicSupervisor do
  @moduledoc false
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_schedule(workflow_id, schedule) do
    DynamicSupervisor.start_child(__MODULE__, {ETLSystem.Scheduler, {workflow_id, schedule}})
  end
end
