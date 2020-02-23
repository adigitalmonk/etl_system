defmodule ETLSystem.Events do
  def init_logs do
    :telemetry.attach(
      "etl_started",
      [:etl, :run, :started],
      fn [:etl, :run, :started], measurements, metadata, _config ->
        IO.inspect [measurements, metadata], label: "Run Started"
      end,
      nil
    )

    :telemetry.attach(
      "etl_schedule",
      [:etl, :run, :schedule],
      fn [:etl, :run, :schedule], measurements, metadata, _config ->
        IO.inspect [data: measurements, schedule: metadata], label: "Schedule Commence"
      end,
      nil
    )

    :telemetry.attach(
      "etl_finished",
      [:etl, :run, :finished],
      fn [:etl, :run, :finished], measurements, metadata, _config ->
        IO.inspect [ data: measurements, workflow: metadata], label: "Run Finished"
      end,
      nil
    )

    :telemetry.attach(
      "etl_failed",
      [:etl, :run, :failed],
      fn [:etl, :run, :failed], measurements, metadata, _config ->
        IO.inspect [ data: measurements, workflow: metadata], label: "Run Failed"
      end,
      nil
    )

    :telemetry.attach(
      "action_started",
      [:etl, :run, :action],
      fn [:etl, :run, :action], measurements, metadata, _config ->
        IO.inspect [ data: measurements, workflow: metadata], label: "Task Started"
      end,
      nil
    )
  end
end
