defmodule Fun.Mixfile do
  use Mix.Project

  def project do
    [app: :fun,
     version: "0.0.2",
     elixir: ">= 1.1.0",
     description: "Functional Elixir",
     elixirc_paths: ["src"],
     compilers: Mix.compilers,
     deps: deps,
     package: package]
  end

  def application do
    [
      applications: []
    ]
  end

  defp deps do
    []
  end

  defp package do
    [files: ~w(lib mix.exs README.md LICENSE UNLICENSE VERSION),
     contributors: ["Avdi Grimm", "meh", "José Valim", "Patrik Storm"],
     licenses: ["WTFNMFPL"],
     links: %{"GitHub" => "https://github.com/tycho01/fun"}]
  end
end
