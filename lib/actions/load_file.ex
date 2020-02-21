defmodule Action.LoadFile do
  @moduledoc false
  def run(args) do
    IO.inspect(args, label: "Load File w/ Arg!")
    "alpha"
  end
end
