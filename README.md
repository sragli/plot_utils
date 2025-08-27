# PlotUtils

Elixir utilities for creating complex visualizations of data.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `plot_utils` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plot_utils, "~> 0.1.0"}
  ]
end
```

## Features

* `array_plot/1` function that replicates Wolfram Language's `ArrayPlot[]` functionality using Kino for visualization

## Color Schemes Available

* `:grayscale` - Traditional black to white mapping
* `:viridis` - Perceptually uniform colormap (purple to yellow)
* `:plasma` - High contrast colormap (purple to pink to yellow)
* `:coolwarm` - Blue to red diverging colormap

## Uage

```elixir
tensor = Nx.tensor([[0, 1, 0], [1, 0, 1], [0, 1, 0]])

# Basic usage
ArrayPlot.array_plot(tensor)

# With options
ArrayPlot.array_plot(tensor, 
  colorscheme: :viridis, 
  title: "My Data", 
  width: 500, 
  height: 400,
  show_values: true)
```