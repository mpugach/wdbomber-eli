defmodule Wdbomber.MixProject do
  use Mix.Project

  def project do
    [
      app: :wdbomber,
      version: "0.1.0",
      elixir: "~> 1.8",
      escript: [main_module: Wdbomber],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:flow, "~> 0.14"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"}
    ]
  end
end
