import Config

config :etl_system, ETLSystem.Workflows, [
  [
    id: "branch_to_count",
    steps: [
      {Examples.Branch, "count"}
    ]
  ],
  [
    id: "count_to_ten",
    steps: [
      {Examples.Counter, 10}
    ]
  ],
  [
    id: "pass_then_fail",
    steps: [
      {Examples.FailTask, "pass"},
      {Examples.FailTask, "fail"}
    ]
  ]
]
