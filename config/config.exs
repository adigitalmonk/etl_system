import Config

config :etl_system, ETLSystem.Tasks, [Action.LoadFile, Action.MangleData, Action.WriteFile]

config :etl_system, ETLSystem.Workflows, [
  [
    task_id: "first",
    steps: [
      {Action.LoadFile, "data/test.txt"},
      Action.MangleData,
      {Action.WriteFile, "data/test2.txt"}
    ]
  ],
  [
    task_id: "second",
    steps: [
      Action.MangleData,
      {Action.MangleData, "data/test1.txt"},
      Action.MangleData
    ]
  ],
  [
    task_id: "failure",
    steps: [
      {Action.WriteFile, "data/test2.txt"},
      {Action.LoadFile, "fail"}
    ]
  ]
]
