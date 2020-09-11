defmodule Db2file.MixProject do
  use Mix.Project

  def project do
    [
      app: :db2file,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto, :jamdb_oracle, :jason, :timex],
      mod: {Db2file.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~>3.4.6"},
      {:jason, "~>1.2.1"},
      {:jamdb_oracle, "~>0.4.1"},
      # {:mongodb, "~>0.5.1"},
      # {:poolboy, "~>1.5.2"},
      {:timex, "~>3.6.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
