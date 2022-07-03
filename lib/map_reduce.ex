defmodule MapReduce do
  @type input_key :: any()
  @type input_value :: any()
  @type input_map :: [{input_key(), input_value()}]
  @type intermediate_value :: any()
  @type intermediate_map :: [{output_key(), intermediate_value()}]
  @type output_key :: any()
  @type output_value :: any()
  @type output_map :: [{output_key(), output_value()}]

  @doc """
  Apply some function to the input data to produce a list of key value pairs to
  be passed to the reduce callback function.
  """
  @callback map(key :: input_key(), value :: input_value()) ::
              intermediate_map()

  @doc """
  Takes a set of values associated with a given key as produced by the map
  callback function and reduces them to create a list of output values.
  """
  @callback reduce(key :: output_key(), values :: [intermediate_value()]) ::
              [output_value()]

  @doc """
  Takes a dataset of key value pairs and applies to the MapReduce algorithm,
  producing a list of output key value pairs.

  TODO: Switch to a distributed architecture rather than this simple naive sequential approach
  """
  @spec run(module(), input_map()) :: output_map()
  def run(implementation, input) do
    input
    |> Enum.map(fn {key, value} -> implementation.map(key, value) end)
    |> group_by_key
    |> Enum.map(fn {key, values} -> implementation.reduce(key, values) end)
  end

  @doc """
  iex> MapReduce.collect([[{:a, 1}, {:b, 2}], [{:b, 5}, {:c, 6}, {:d, 0}], [{:a, 3}]])
  %{a: [3, 1], b: [5, 2], c: [6], d: [0]}
  """
  @spec group_by_key([intermediate_map()]) :: %{output_key() => [intermediate_value()]}
  defp group_by_key(inter_maps) do
    inter_maps
    |> Stream.flat_map(fn x -> x end)
    |> Enum.reduce(
      %{},
      fn {out_key, inter_value}, acc ->
        Map.update(
          acc,
          out_key,
          [inter_value],
          fn acc ->
            [inter_value | acc]
          end
        )
      end
    )
  end
end
