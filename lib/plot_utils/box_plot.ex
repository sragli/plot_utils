defmodule BoxPlot do
  alias VegaLite, as: Vl

  def plot_map(map, group_key \\ "group", value_key \\ "value", opts \\ []) do
    data =
      for {g, values} <- map, v <- values do
        %{group_key => g, value_key => v}
      end
    plot(data, group_key, value_key, opts)
  end

  def plot(data, group_field, value_field, opts \\ []) do
    title     = Keyword.get(opts, :title, "")
    width     = Keyword.get(opts, :width, 700)
    height    = Keyword.get(opts, :height, 400)
    extent    = Keyword.get(opts, :extent, 1.5)   # Tukey default
    tooltip?  = Keyword.get(opts, :tooltip, true)
    x_title   = Keyword.get(opts, :x_title, to_string(group_field))
    y_title   = Keyword.get(opts, :y_title, to_string(value_field))

    group_s = to_string(group_field)
    value_s = to_string(value_field)

    Vl.new(title: title, width: width, height: height)
    |> Vl.data_from_values(data, only: [group_s, value_s])
    |> Vl.mark(:boxplot, extent: extent)
    |> Vl.encode_field(:x, group_s, type: :nominal, title: x_title)
    |> Vl.encode_field(:y, value_s, type: :quantitative, title: y_title)
    |> maybe_add_tooltip(tooltip?, group_s, value_s)
  end

  defp maybe_add_tooltip(vl, true, group_s, value_s) do
    vl
    |> Vl.encode_field(:tooltip, group_s, type: :nominal)
    |> Vl.encode_field(:tooltip, value_s, type: :quantitative)
  end

  defp maybe_add_tooltip(vl, _false, _group_s, _value_s), do: vl
end
