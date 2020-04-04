defmodule ETLSystem.Scheduler.State do
  @moduledoc """
  This struct stores the state for a running scheduler.
  """

  @typedoc """
  Structure of the state of a workflow
  """
  @type t :: %__MODULE__{workflow_id: binary(), schedule: term(), timer: term()}
  defstruct [:workflow_id, :schedule, :timer]

  @doc """
  Build a new workflow scheduler state
  """
  def new(workflow_id, schedule) do
    %__MODULE__{
      workflow_id: workflow_id,
      schedule: schedule,
      timer: schedule_next(schedule)
    }
  end

  @doc false
  def next(state, timer) do
    %__MODULE__{
      state
      | timer: timer
    }
  end

  @doc """
  Kick off the workflow defined in this scheduler
  """
  def start(state) do
    updated_state = %__MODULE__{
      state
      | timer: schedule_next(state.schedule)
    }

    :telemetry.execute(
      [:etl, :run, :schedule],
      %{
        workflow_id: updated_state.workflow_id,
        timestamp: DateTime.utc_now()
      },
      updated_state
    )

    ETLSystem.Orchestrator.run_workflow(updated_state.workflow_id)

    updated_state
  end

  @periods ["hour", "minute", "day"]

  defp seconds_until_next(period) do
    case period do
      "minute" ->
        60 - DateTime.utc_now().second

      "hour" ->
        (60 - DateTime.utc_now().minute) * 60

      "day" ->
        (24 - DateTime.utc_now().hour) * 60 * 60
    end
  end

  defp schedule_next({:frequency, frequency}) when frequency in @periods do
    Process.send_after(self(), :tick, seconds_until_next(frequency) * 1000)
  end

  defp schedule_next({:frequency, _}), do: nil

  defp schedule_next({:schedule, "minute"}) do
    Process.send_after(self(), :tick, 60_000)
  end

  defp schedule_next({:schedule, "second"}) do
    Process.send_after(self(), :tick, 1_000)
  end

  defp schedule_next({:schedule, timeout}) do
    Process.send_after(self(), :tick, timeout)
  end
end
