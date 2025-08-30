# PlotUtils

Elixir utilities for creating complex visualizations of data.

## Installation

The package can be installed by adding `plot_utils` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plot_utils, "~> 0.1.0"}
  ]
end
```

## Features

* `PlotUtils.ArrayPlot.plot/2` - Function that replicates Wolfram Language's `ArrayPlot[]` functionality using Kino for visualization
* `PlotUtils.ArrayPlot.tile_plot/2` - Displays multiple plots in a tiling manner

## Color Schemes Available

* `:grayscale` - Traditional black to white mapping
* `:viridis` - Perceptually uniform colormap (purple to yellow)
* `:plasma` - High contrast colormap (purple to pink to yellow)
* `:coolwarm` - Blue to red diverging colormap

## Usage

```elixir
tensor = Nx.tensor([[0, 1, 0], [1, 0, 1], [0, 1, 0]])

# Basic usage
PlotUtils.ArrayPlot.plot(tensor)

# With options
PlotUtils.ArrayPlot.plot(tensor, 
  colorscheme: :viridis, 
  title: "My Data", 
  width: 500, 
  height: 400,
  show_values: true)
```