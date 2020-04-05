defmodule ETLSystem.Tasks.StreamFile do
  @moduledoc """
  Task that will set up a file stream.
  The stream will be passed on to the next step in the workflow.

  This task does not confirm that the file to load exists.
  """
  use ETLSystem.Task

  @doc false
  def run(%{args: filename} = workflow) do
    {:ok, File.stream!(filename), workflow}
  end
end
