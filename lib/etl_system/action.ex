defmodule ETLSystem.Action do
  @moduledoc false
  use GenServer

  def start_link(action_module) do
    GenServer.start_link(__MODULE__, action_module, name: get_name(action_module))
  end

  defp get_name(id) do
    {:via, Registry, {ETLSystem.Action.Registry, id}}
  end

  @impl true
  def init(action_module) do
    # Test if run/1 and run/0 exist?
    # Do I even care?
    {:ok, action_module}
  end

  def run(%Workflow{ next: [ {next, args} | rest ]} = workflow) do
    workflow = 
      workflow
      |> Map.put(:args, args)
      |> Map.put(:next, rest)

    get_name(next)
    |> GenServer.cast({:run, workflow})
  end

  def run(%Workflow{ next: [ next | rest ]} = workflow) do
    get_name(next)
    |> GenServer.cast({:run, Map.put(workflow, :next, rest)})
  end

  def run(%Workflow{ next: [] } = workflow) do
    IO.inspect workflow, label: "Finished Workflow"
  end

  @impl true
  def handle_cast({:run, workflow}, mod) do
    workflow
    |> Map.put(:previous, apply(mod, :run, workflow))
    |> __MODULE__.run()

    {:noreply, mod}
  end

  def handle_cast(_thing, mod) do
    # IO.inspect thing, label: "Cast"
    {:noreply, mod}
  end
end
