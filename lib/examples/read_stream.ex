defmodule Examples.ReadStream do
  @moduledoc false
  use ETLSystem.Task

  def run(%{previous: stream} = workflow) do
    line1 =
      stream
      |> Enum.take(1)

    {:ok, line1, workflow}
  end
end
