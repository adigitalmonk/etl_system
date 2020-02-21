defmodule Action.Branch do
  def run(%{ previous: previous, next: next } = workflow) do
    next = 
        if previous == "test" do
            [ Action.LoadFile | next ]
        else 
            next
        end 

    {:ok, Map.put(workflow, :next, next})
  end
end
