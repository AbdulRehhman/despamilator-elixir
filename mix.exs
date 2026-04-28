defmodule Despamilator.MixProject do
  use Mix.Project

  def project do
    [
      app: :despamilator,
      version: "2.1.4",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps, do: []

  defp description do
    "Plugin-based heuristic spam scanner for free-text web form input. " <>
      "Elixir port of the Ruby despamilator gem."
  end

  defp package do
    [
      licenses: ["MIT"],
      files: ~w(lib priv mix.exs README.md)
    ]
  end
end
