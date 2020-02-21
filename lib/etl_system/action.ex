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

  def run(steps, previous \\ nil)

  def run([{action_module, args} | next_steps], previous) do
    get_name(action_module)
    |> GenServer.cast({:run, args, previous, next_steps})
  end

  def run([action_module | next_steps], previous) do
    get_name(action_module)
    |> GenServer.cast({:run, previous, next_steps})
  end

  @impl true
  def handle_call(_msg, _from, mod) do
    # IO.inspect msg, label: "Call"
    {:noreply, mod}
  end

  @impl true
  def handle_cast({:run, previous, next}, mod) do
    output = apply(mod, :run, [[previous: previous]])
    if next != [], do: __MODULE__.run(next, output)
    {:noreply, mod}
  end

  def handle_cast({:run, args, previous, next}, mod) do
    output = apply(mod, :run, [[args: args, previous: previous]])
    if next != [], do: __MODULE__.run(next, output)
    {:noreply, mod}
  end

  def handle_cast(_thing, mod) do
    # IO.inspect thing, label: "Cast"
    {:noreply, mod}
  end
end
