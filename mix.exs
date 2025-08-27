defmodule PlotUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :plot_utils,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "PlotUtils",
      source_url: "https://github.com/sragli/plot_utils",
      docs: docs()

    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nx, "~> 0.6"},
      {:kino, "~> 0.11"},
      {:vega_lite, "~> 0.1"},
      {:kino_vega_lite, "~> 0.1"},
    ]
  end

  defp description() do
    "Elixir utilities for creating complex visualizations of data."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/sragli/plot_utils"}
    ]
  end

  defp docs() do
    [
      main: "PlotUtils",
      extras: ["README.md", "LICENSE", "CHANGELOG"]
    ]
  end
end
