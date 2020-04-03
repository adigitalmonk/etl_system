defmodule ETLSystem.Scheduler.DynamicSupervisor do
  @moduledoc false
  use DynamicSupervisor

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a new schedule process for a given workflow by it's workflow_id and schedule
  """
  def start_schedule(workflow_id, schedule) do
    DynamicSupervisor.start_child(__MODULE__, {ETLSystem.Scheduler, {workflow_id, schedule}})
  end
end
