defmodule Day22 do
  def part1(input, deck_size \\ 10_007) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    deck = Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc)
    end)
    case deck_size do
      10_007 ->
        Enum.find_index(deck, & &1 === 2019)
      _ ->
        deck
    end
  end

  def part2(input) do
    deck_size = 119315717514047
    times = 101741582076661
  end

  @part2_position 2020
  def brute_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc)
    end)
    |> Enum.at(target)
  end

  def lazy_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    input = parse_input(input)
    {result, _} = Enum.reverse(input)
    |> Enum.reduce({target, deck_size}, fn technique, acc ->
      lazy_step(technique, acc)
    end)
    result
  end

  defp lazy_step(:deal, {pos, size}) do
    {size - pos - 1, size}
  end
  defp lazy_step({:deal, inc}, {target_pos, size}) do
    incs_per_cycle = div(size, inc)
    rem_per_cycle = rem(size, inc)
    info = {inc * incs_per_cycle, inc, rem_per_cycle, size}
    {backward_deal(target_pos, info, 0), size}
  end
  defp lazy_step({:cut, n}, {pos, size}) do
    {rem(size + pos + n, size), size}
  end

  defp backward_deal(target, {cycle, inc, rem, size} = info, sum) do
    if rem(inc - rem(sum, inc), inc) === rem(target, inc) do
      div(sum + target, inc)
    else
      backward_deal(target, info, sum + size)
    end
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
