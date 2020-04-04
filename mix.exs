defmodule ETLSystem.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :etl_system,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ETLSystem.Application, []}
    ]
  end

  defp aliases do
    [
      check: ["format", "credo --strict", "inch"],
      build: ["check", "compile"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev], runtime: false},
      {:inch_ex, "~> 2.0", only: [:dev], runtime: false},
      {:telemetry, "~> 0.4.1"}
    ]
  end
end
