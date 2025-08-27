defmodule PlotUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :plot_utils,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
