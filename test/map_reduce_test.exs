defmodule MapReduceTest do
  use ExUnit.Case
  doctest MapReduce

  defmodule MapReduceLetterCount do
    @behaviour MapReduce

    @doc """
    iex> map(nil, "hello")
    [{"h", 1}, {"e", 1}, {"l", 1}, {"l", 1}, {"o", 1}, ]
    """
    @impl MapReduce
    def map(_key, word) do
      word
      |> String.graphemes()
      |> Enum.reduce([], fn char, acc -> [{char, 1} | acc] end)
    end

    @doc """
    iex> reduce("l", [1, 1])
    {"l", [2]}
    """
    @impl MapReduce
    def reduce(char, counts) do
      {char, [Enum.reduce(counts, &+/2)]}
    end
  end

  test "basic string letter count implementation works" do
    words = ["hello", "world", "foo", "bar", "baz"]
    input = Enum.map(words, &{nil, &1})

    result =
      MapReduce.run(MapReduceLetterCount, input)
      |> Enum.into(%{})

    assert result == %{
             "a" => [2],
             "b" => [2],
             "d" => [1],
             "e" => [1],
             "f" => [1],
             "h" => [1],
             "l" => [3],
             "o" => [4],
             "r" => [2],
             "w" => [1],
             "z" => [1]
           }
  end
end
