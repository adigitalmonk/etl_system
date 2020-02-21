defmodule Action.WriteFile do
  @moduledoc false
  def run(args) do
    IO.inspect(args, label: "Write File w/ Arg!")
    "gamma"
  end
end
