defmodule Day22 do
  def part1(input, deck_size \\ 10_007) do
    deck = 0..deck_size-1 |> Enum.to_list
    input = parse_input(input)
    deck = Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc)
    end)
    ^deck_size = Enum.count(deck)
    case deck_size do
      10_007 ->
        Enum.find_index(deck, & &1 === 2019)
      _ ->
        deck
    end
  end

  def part2(input) do
  end

  defp one_step(:deal, deck) do
    Enum.reverse(deck)
  end
  defp one_step({:deal, inc}, deck) do
    deck_size = Enum.count(deck)
    table = 0..deck_size-1
    |> Enum.map(& {&1, :empty})
    |> Map.new
    Stream.iterate(0, & rem(&1 + inc, deck_size))
    |> Enum.reduce_while({table, deck}, fn pos, {table, deck} ->
      case deck do
        [top | rest] ->
          {:cont, {Map.put(table, pos, top), rest}}
        [] ->
          deck = Map.to_list(table)
          |> Enum.sort
          |> Enum.map(& elem(&1, 1))
          {:halt, deck}
      end
    end)
  end
  defp one_step({:cut, n}, deck) do
    {first, rest} = Enum.split(deck, n)
    rest ++ first
  end

  defp parse_input(input) do
    Enum.map(input, fn line ->
      case line do
        "deal into new stack" ->
          :deal
        "deal with increment " <> int ->
          {:deal, String.to_integer(int)}
        "cut " <> int ->
          {:cut, String.to_integer(int)}
      end
    end)
  end
end
