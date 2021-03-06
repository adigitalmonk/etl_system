# ETLSystem

This is a simple application for running concurrent tasks in a given order.
It consists of two components: tasks and workflows.

## Installation

```elixir
def deps do
  [
    {:etl_system, "~> 0.1.0"}
  ]
end
```
(TODO: Replace with GitHub link)

## Usage

Adding this system to your application requires two things.
The first is to define tasks in your application.
A task is a module that contains `use ETLSystem.Task` and implements the `run/1` function.
The second part is to define workflows in your configuration.


### Task

This is an example task that will load a file.

```elixir
defmodule ETLSystem.Tasks.LoadFile do
  @moduledoc """
  Task that will load a file.
  The loaded data will be passed on to the next step in the workflow.
  """
  use ETLSystem.Task

  @doc false
  def run(%{args: filename} = workflow) do
    case File.open(filename) do
      {:ok, file_data} ->
        {:ok, file_data, workflow}

      {:error, reason} ->
        {:err, reason, workflow}
    end
  end
end
```

A task receives an `ETLSystem.Workflow` struct.
This structure contains the following information:

```elixir
iex(1)> %ETLSystem.Workflow{}
%ETLSystem.Workflow{
  args: nil, # The argument data included in the workflow definition
  id: nil, # The name of the defined workflow
  next: nil, # An array of the remaining steps in the workflow 
  previous: nil, # The output of the previous step's execution
  run_id: nil, # A randomly generated ID for this current step through the process
}
```

Any step in the workflow can manipulate any of these values, so bear that in mind when you are deciding what to do for a given step.
This includes changing the future steps in the workflow.
See the Advanced section for more.

### Workflows

Now that you've created several tasks, it's time to orchestrate them together.

Let's say you've got a workflow intended for reading a CSV file and saving it to the database.
You've created two custom actions:
- `SomeProject.Actions.CSVToRecords` which converts a CSV file data into a format to write to the database (perhaps some clean up of data as well)
- `SomeProject.Actions.SaveRecordsToDatabase` which accepts the format of the data you are outputing from `.CSVToRecords`

A configuration for that would look something like the following:
```elixir
config :etl_system, ETLSystem.Workflows, [
  [
    id: "read_file_to_database",
    steps: [
      {ETLSystem.Tasks.LoadFile, "data/customer_records.csv"},
      SomeProject.Actions.CSVToRecords,
      SomeProject.Actions.SaveRecordsToDatabase
    ]
  ]
]
```

The `steps` param taks a list and will run each step in order.
For `.LoadFile`, the `args` for the step will be `"data/customer_records.csv"`.
This is the value that is included in the tuple for the step.
In the remaining two steps, the `args` will be `nil` as they are not passed in as a tuple.
For `.CSVToRecords`, the `previous` value for the workflow will be the data from `File.read/1`, and subsequently `.SaveRecordsToDatabase` will be the result of those tweaks.


Now whenever you want to trigger this new workflow, you can use the following:

```elixir
iex(1)> ETLSystem.Orchestrator.run_workflow("read_file_to_database")
```

### Telemetry Events

The following events are published.

| Event tags | Purpose | Measurement | Metadata |
| :--------- | :------ | :---------- | :------- |
| `[:etl, :run, :started]` | A workflow has begun. | Map containing the current UTC timestamp. | Current state of the workflow in the form of an `ETLSystem.Workflow{}` |
| `[:etl, :run, :finished]` | A workflow has finished the entire process. | Map containing the current UTC timestamp. | Current state of the workflow in the form of an `ETLSystem.Workflow{}` |
| `[:etl, :run, :failed]` | A workflow has failed to complete. | Map containing the current UTC timestamp. | Current state of the workflow in the form of an `ETLSystem.Workflow{}` |
| `[:etl, :run, :action]` | An individual task in the workflow has completed. | Map containing the current UTC timestamp and the current task that is starting. | Current state of the workflow in the form of an `ETLSystem.Workflow{}` |

### Advanced Features

Due to the nature of being able to alter the state of the workflow mid-execution, a given task has a lot of control over everything that follows it.

One useful feature of this is the ability to affect future steps in the process.
This allows us to create both recursive steps as well as branching steps.

#### Example Branching

In the following example, we see that if the previous step returned the string `"load"` then we inject the task `Example.LoadFile` at the front of our next steps.

```elixir
defmodule Example.Branch do
  @moduledoc """
  Example branching task
  """
  use ETLSystem.Task

  @doc """
  If the previous result was "load", inject the LoadFile task as the next step
  Otherwise, just continue on with the next steps.
  """
  def run(%{previous: "load", next: next} = workflow) do
    {:ok, nil, next_up(workflow, Example.LoadFile)}
  end

  def run(workflow) do
    {:ok, nil, workflow}
  end
end
```

#### Example Recursion

In the following example, the task will take in some target value and will continualy inject itself back into the front of the stack until the result of the previous execution is the target that it keeps carrying forward.

The tasks `sleep` for half a second to simulate some actual activity happening.

```elixir
import Config

config :etl_system, ETLSystem.Workflows, [
  [
    id: "count_to_ten",
    steps: [
      {Example.Counter, 10}
    ]
  ]
]
```

```elixir
defmodule Examples.Counter do
  @moduledoc """
  Example task that updates the next steps to simulate counting
  """
  use ETLSystem.Task

  @doc """
  For a given step, if the previous result hasn't reached the target value yet,
  inject this module back into the workflow and increment the return value
  based on the value of the previous result
  """
  def run(%{previous: nil, args: target} = workflow) do
    Process.sleep(500)
    {:ok, 1, next_up(workflow, __MODULE__, target)}
  end

  def run(%{previous: previous, args: target} = workflow) when previous >= target do
    {:ok, previous, workflow}
  end

  def run(%{previous: previous, args: target} = workflow) do
    Process.sleep(500)
    {:ok, previous + 1, next_up(workflow, __MODULE__, target)}
  end
end
```

# Roadmap
- Tests
- Replace "Example" tasks with "Basic" tasks
- Better defined Telemetry events
- Ability to "Call" vs. "Cast" for running a workflow
