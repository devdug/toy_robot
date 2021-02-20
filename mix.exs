defmodule ToyRobot.MixProject do
  use Mix.Project

  def project do
    [
      app: :toy_robot,
      version: "0.1.0",
      elixir: "~> 1.11",
      escript: [main_module: ToyRobot.CLI],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ToyRobot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.23.0", only: [:dev]}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
