defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:egd, github: "erlang/egd"},
      {:ex_termbox, "~> 0.3"},
      {:exprof, "~> 0.2.0"},
      {:eflame, ~r/.*/, git: "https://github.com/proger/eflame.git", compile: "rebar compile"}
    ]
  end
end
