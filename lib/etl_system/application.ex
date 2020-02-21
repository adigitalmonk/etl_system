defmodule ETLSystem.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: ETLSystem.Action.Supervisor},
      ETLSystem.Orchestrator
    ]

    opts = [strategy: :one_for_one, name: ETLSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
