import Config

config :etl_system, ETLSystem.Workflows, [
  [
    task_id: "new",
    steps: [
      Action.Branch,
      {Action.Branch, "text"}
    ]
  ],
  [
    task_id: "count",
    steps: [
      {Action.Counter, 10}
    ]
  ],
  [
    task_id: "first",
    steps: [
      {Action.LoadFile, "data/test.txt"},
      Action.MangleData,
      {Action.WriteFile, "data/test2.txt"}
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
