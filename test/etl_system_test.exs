defmodule ETLSystemTest do
  use ExUnit.Case
  doctest ETLSystem

  test "greets the world" do
    assert ETLSystem.hello() == :world
  end
end
