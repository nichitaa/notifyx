defmodule Guava.MixProject do
  use Mix.Project

  def project do
    [
      app: :guava,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Guava.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.6.12"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:mail, ">= 0.0.0"},
      # nodes cluster manager
      {:libcluster, "~> 3.3"},
      # swoosh api client
      {:finch, "~> 0.13"},
      # google oauth
      {:goth, "~> 1.3"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
