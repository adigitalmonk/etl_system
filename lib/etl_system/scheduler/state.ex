defmodule ETLSystem.Scheduler.State do
  defstruct [:workflow_id, :schedule, :timer]

  def new(workflow_id, schedule) do
    %__MODULE__{
      workflow_id: workflow_id,
      schedule: schedule,
      timer: schedule_next(schedule)
    }
  end

  def new(workflow_id, schedule, timer) do
    %__MODULE__{
      workflow_id: workflow_id,
      schedule: schedule,
      timer: timer
    }
  end

  def next(state, timer) do
    %__MODULE__{
      state |
      timer: timer
    }
  end

  def next?(state), do: state.timer

  def start(state) do
    :telemetry.execute(
      [:etl, :run, :schedule],
      %{
        workflow_id: state.workflow_id,
        timestamp: DateTime.utc_now()
      },
      state
    )

    ETLSystem.Orchestrator.run_workflow(state.workflow_id)

    %__MODULE__{
      state |
      timer: schedule_next(state.schedule)
    }
  end

  #### Logic
  # defp next_minute() do
  #   DateTime.utc_now()
  #   |> DateTime.to_unix()
  #   |> div(60)
  #   |> Kernel.*(60)
  #   |> DateTime.from_unix!()
  # end

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
