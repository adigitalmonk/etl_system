defmodule ETLSystem.Tasks.LoadFile do
  @moduledoc """
  Task that will load a file.
  The loaded data will be passed on to the next step in the workflow.
  """
  use ETLSystem.Task

  @doc false
  def run(%{args: filename} = workflow) do
    case File.open(filename) do
      {:ok, file_data} ->
        {:ok, file_data, workflow}

      {:error, reason} ->
        {:err, reason, workflow}
    end
  end
end
