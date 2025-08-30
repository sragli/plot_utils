defmodule PlotUtils.ArrayPlot do
  @moduledoc """
  Implementation of ArrayPlot functionality similar to Wolfram Language's ArrayPlot[]
  using Kino for visualization in Elixir/Livebook.
  """

  @doc """
  Creates an array plot visualization of a 2D matrix using Kino.

  ## Parameters
  - `data`: Nx.Tensor.t() | list of lists - A 2D tensor to visualize
  - `opts`: Keyword list of options
    - `:colorscheme` - Color scheme to use (default: :grayscale)
    - `:width` - Width of the plot in pixels (default: 400)
    - `:height` - Height of the plot in pixels (default: 400)
    - `:title` - Title for the plot (default: "Array Plot")
    - `:show_values` - Whether to show numeric values in cells (default: false)
    - `:show_colorbar` - Display/turn off color bar (default: true)
  """
  @spec plot(Nx.Tensor.t() | list(), list(keyword())) :: Kino.Image.t()
  def plot(matrix, opts) do
    colorscheme = Keyword.get(opts, :colorscheme, :grayscale)
    width = Keyword.get(opts, :width, 400)
    height = Keyword.get(opts, :height, 400)
    title = Keyword.get(opts, :title, "Array Plot")
    show_values = Keyword.get(opts, :show_values, false)
    show_colorbar = Keyword.get(opts, :show_colorbar, true)

    matrix
    |> convert_matrix()
    |> generate_svg(
      colorscheme,
      width,
      height,
      title,
      show_values,
      show_colorbar
    )
    |> Kino.Image.new(:svg)
  end

  @doc """
  Displays several plots in one image.

  ## Parameters
  - `data`: Map of Nx.Tensor.t(), key: title, value: tensor - 2D tensors to visualize
  - `opts`: Keyword list of options
    - `:colorscheme` - Color scheme to use (default: :grayscale)
    - `:width` - Width of an individual plot in pixels (default: 250)
    - `:height` - Height of individual plot in pixels (default: 250)
  """
  @spec tile_plot(map(), list(keyword())) :: Kino.HTML.t()
  def tile_plot(multi_data, opts \\ []) when is_map(multi_data) do
    colorscheme = Keyword.get(opts, :colorscheme, :grayscale)
    width = Keyword.get(opts, :width, 250)
    height = Keyword.get(opts, :height, 250)

    svgs =
      Enum.map(multi_data, fn {title, matrix} ->
        matrix
        |> convert_matrix()
        |> generate_svg(colorscheme, width, height, title)
      end)

    # TODO dynamic tiling
    """
    <div style="display: grid; grid-template-columns: repeat(3, #{width}px); gap: 10px;">
      #{Enum.map(svgs, fn svg -> "<div>" <> svg <> "</div>" end)}
    </div>
    """
    |> Kino.HTML.new()
  end

  # Normalize data to 0-1 range for color mapping
  defp normalize(data, min_val, max_val) do
    if min_val == max_val do
      # Handle constant data
      Enum.map(data, fn row ->
        Enum.map(row, fn _ -> 0.5 end)
      end)
    else
      Enum.map(data, fn row ->
        Enum.map(row, fn val ->
          (val - min_val) / (max_val - min_val)
        end)
      end)
    end
  end

  defp convert_matrix(%Nx.Tensor{} = data) do
    unless Nx.rank(data) == 2 do
      raise ArgumentError, "requires a 2D tensor, got rank #{Nx.rank(data)}"
    end

    Nx.to_list(data)
  end

  defp convert_matrix(data), do: data

  defp generate_svg(
         data,
         colorscheme,
         width,
         height,
         title,
         show_values \\ false,
         show_colorbar \\ false
       ) do
    rows = length(data)
    cols = length(hd(data))

    flat_data = List.flatten(data)
    min_val = Enum.min(flat_data)
    max_val = Enum.max(flat_data)

    # Calculate cell dimensions
    plot_width = width * 0.8
    plot_height = height * 0.7
    cell_width = plot_width / cols
    cell_height = plot_height / rows

    # Offset for centering
    x_offset = width * 0.1
    y_offset = height * 0.15

    # Generate cells
    cells =
      data
      |> normalize(min_val, max_val)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, row_idx} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {value, col_idx} ->
          x = x_offset + col_idx * cell_width
          y = y_offset + row_idx * cell_height
          color = get_color(value, colorscheme)

          cell_svg = """
          <rect x="#{x}" y="#{y}" width="#{cell_width}" height="#{cell_height}"
                fill="#{color}" stroke="#ffffff" stroke-width="0.5"/>
          """

          text_svg =
            if show_values do
              original_val =
                if min_val == max_val do
                  min_val
                else
                  min_val + value * (max_val - min_val)
                end

              text_x = x + cell_width / 2
              text_y = y + cell_height / 2
              font_size = min(cell_width, cell_height) * 0.3

              """
              <text x="#{text_x}" y="#{text_y}" text-anchor="middle" dominant-baseline="central"
                    font-family="Arial, sans-serif" font-size="#{font_size}"
                    fill="#{if value > 0.5, do: "white", else: "black"}">
                #{Float.round(original_val, 2)}
              </text>
              """
            else
              ""
            end

          cell_svg <> text_svg
        end)
      end)
      |> Enum.join("\n")

    # Generate colorbar
    colorbar = generate_colorbar(colorscheme, width, height, {min_val, max_val}, show_colorbar)

    """
    <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
      <style>
        .title { font-family: Arial, sans-serif; font-size: 16px; font-weight: bold; }
        .axis-label { font-family: Arial, sans-serif; font-size: 12px; }
      </style>

      <rect x="0.5" y="0.5" width="#{width - 1}" height="#{height - 1}" stroke="#000000" stroke-width="1" fill="none"/>

      <text x="#{width / 2}" y="25" text-anchor="middle" class="title">#{title}</text>

      #{cells}

      #{colorbar}

      <text x="#{x_offset}" y="#{height - 10}" class="axis-label">#{rows}×#{cols}</text>
    </svg>
    """
  end

  defp generate_colorbar(colorscheme, width, height, {min_val, max_val}, true) do
    colorbar_width = 20
    colorbar_height = height * 0.5
    colorbar_x = width * 0.92
    colorbar_y = height * 0.25

    # Generate gradient stops
    gradient_stops =
      0..10
      |> Enum.map(fn i ->
        offset = i / 10
        color = get_color(offset, colorscheme)
        "<stop offset=\"#{offset * 100}%\" stop-color=\"#{color}\"/>"
      end)
      |> Enum.join("\\n")

    """
    <defs>
      <linearGradient id="colorbar-gradient" x1="0%" y1="100%" x2="0%" y2="0%">
        #{gradient_stops}
      </linearGradient>
    </defs>

    <!-- Colorbar rectangle -->
    <rect x="#{colorbar_x}" y="#{colorbar_y}" width="#{colorbar_width}" height="#{colorbar_height}"
          fill="url(#colorbar-gradient)" stroke="#333" stroke-width="1"/>

    <!-- Colorbar labels -->
    <text x="#{colorbar_x + colorbar_width + 5}" y="#{colorbar_y + 5}" class="axis-label">#{max_val}</text>
    <text x="#{colorbar_x + colorbar_width + 5}" y="#{colorbar_y + colorbar_height}" class="axis-label">#{min_val}</text>
    """
  end

  defp generate_colorbar(_colorscheme, _width, _height, {_min_val, _max_val}, false) do
    ""
  end

  defp get_color(value, :viridis) do
    cond do
      value < 0.25 ->
        r = round(68 + value * 4 * (85 - 68))
        g = round(1 + value * 4 * (104 - 1))
        b = round(84 + value * 4 * (109 - 84))
        "rgb(#{r}, #{g}, #{b})"

      value < 0.5 ->
        t = (value - 0.25) * 4
        r = round(85 + t * (43 - 85))
        g = round(104 + t * (144 - 104))
        b = round(109 + t * (140 - 109))
        "rgb(#{r}, #{g}, #{b})"

      value < 0.75 ->
        t = (value - 0.5) * 4
        r = round(43 + t * (33 - 43))
        g = round(144 + t * (168 - 144))
        b = round(140 + t * (95 - 140))
        "rgb(#{r}, #{g}, #{b})"

      true ->
        t = (value - 0.75) * 4
        r = round(33 + t * (253 - 33))
        g = round(168 + t * (231 - 168))
        b = round(95 + t * (37 - 95))
        "rgb(#{r}, #{g}, #{b})"
    end
  end

  defp get_color(value, :plasma) do
    cond do
      value < 0.33 ->
        r = round(13 + value * 3 * (126 - 13))
        g = round(8 + value * 3 * (3 - 8))
        b = round(135 + value * 3 * (167 - 135))
        "rgb(#{r}, #{g}, #{b})"

      value < 0.66 ->
        t = (value - 0.33) * 3
        r = round(126 + t * (204 - 126))
        g = round(3 + t * (71 - 3))
        b = round(167 + t * (120 - 167))
        "rgb(#{r}, #{g}, #{b})"

      true ->
        t = (value - 0.66) * 3
        r = round(204 + t * (240 - 204))
        g = round(71 + t * (249 - 71))
        b = round(120 + t * (33 - 120))
        "rgb(#{r}, #{g}, #{b})"
    end
  end

  defp get_color(value, :coolwarm) do
    if value < 0.5 do
      t = value * 2
      r = round(59 + t * (221 - 59))
      g = round(76 + t * (221 - 76))
      b = round(192 + t * (221 - 192))
      "rgb(#{r}, #{g}, #{b})"
    else
      t = (value - 0.5) * 2
      r = round(221 + t * (180 - 221))
      g = round(221 + t * (4 - 221))
      b = round(221 + t * (38 - 221))
      "rgb(#{r}, #{g}, #{b})"
    end
  end

  defp get_color(value, _) do
    # Default to grayscale
    gray = round(255 * (1 - value))
    "rgb(#{gray}, #{gray}, #{gray})"
  end
end
