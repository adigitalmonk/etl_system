defmodule ETLSystem.Tasks.LoadFileTest do
  @moduledoc false
  use ExUnit.Case
  alias ETLSystem.Tasks
  alias ETLSystem.Workflow
  doctest Tasks.LoadFile

  test "loads a file that exists" do
    {result, _file_data, workflow} =
      Tasks.LoadFile.run(%Workflow{
        id: :test_id,
        next: [],
        args: ".gitignore",
        previous: nil,
        run_id: :test_run_id
      })

    assert result == :ok
    assert workflow.run_id == :test_run_id
    assert workflow.next == []
    assert workflow.id == :test_id
  end

  test "fails a file that doesn't exist" do
    {result, file_data, workflow} =
      Tasks.LoadFile.run(%Workflow{
        id: :test_id,
        next: [],
        args: ".gitignor3",
        previous: nil,
        run_id: :test_run_id
      })

    assert result == :err
    assert file_data == :enoent
    assert workflow.run_id == :test_run_id
    assert workflow.next == []
    assert workflow.id == :test_id
  end
end
