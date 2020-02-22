import Config

config :etl_system, ETLSystem.Workflows, [
  [
    id: "new",
    steps: [
      Action.Branch,
      {Action.Branch, "text"}
    ]
  ],
  [
    id: "count",
    schedule: "second",
    steps: [
      {Action.Counter, 10}
    ]
  ],
  [
    id: "first",
    steps: [
      {Action.LoadFile, "data/test.txt"},
      Action.MangleData,
      {Action.WriteFile, "data/test2.txt"}
    ]
  ],
  [
    id: "failure",
    steps: [
      {Action.WriteFile, "data/test2.txt"},
      {Action.LoadFile, "fail"}
    ]
  ]
]
