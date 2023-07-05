defmodule ExVespa.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_vespa,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :docker]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.1.0"},
      {:retry, "~> 0.13.0"},
      {:docker, "~> 0.4.0"}
    ]
  end
end
