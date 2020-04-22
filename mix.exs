defmodule Rwt.MixProject do
  use Mix.Project

  def project do
    [
      app: :rwt,
      version: "0.9.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex],
      mod: {Rwt.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quantum, "~> 3.0-rc"},
      {:jason, "~> 1.2"},
      {:distillery, "~> 2.1"},
      {:timex, "~> 3.5"},
      {:uuid, "~> 1.1"},
      {:tesla, "~> 1.3.0"}
    ]
  end
end
