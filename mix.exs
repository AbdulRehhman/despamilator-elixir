defmodule Despamilator.MixProject do
  use Mix.Project

  @version "2.1.4"
  @source_url "https://github.com/AbdulRehhman/despamilator"

  def project do
    [
      app: :despamilator_elixir,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Despamilator",
      source_url: @source_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Plugin-based heuristic spam scanner for free-text web form input. " <>
      "Elixir port of the Ruby despamilator gem."
  end

  defp package do
    [
      name: "despamilator_elixir",
      maintainers: ["Abdul Rehman"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Upstream Ruby gem" => "https://github.com/moowahaha/despamilator"
      },
      files: ~w(lib priv mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
