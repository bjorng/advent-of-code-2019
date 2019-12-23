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
    deck_size = 119_315_717_514_047
    times = 101_741_582_076_661
    lazy_solve(input, deck_size, 1)
  end

  @part2_position 2020

  def brute_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    brute_stream(input, deck_size)
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd
    |> Enum.at(target)
  end

  defp brute_stream(input, deck_size) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    Stream.iterate(deck, & next_brute(input, &1))
  end

  defp next_brute(input, deck) do
    Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc)
    end)
  end

  def lazy_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    next = lazy_stream(input, deck_size, target)
    |> Stream.drop(times)
    |> Enum.take(1)
    |> hd
    next
  end

  defp lazy_stream(input, deck_size, target) do
    input = parse_input(input)
    input = prepare_lazy_input(input, deck_size)
    input = Enum.reverse(input)
    Stream.iterate(target, & next_lazy(input, deck_size, &1))
  end

  defp next_lazy(input, deck_size, target) do
    Enum.reduce(input, target, fn technique, acc ->
      lazy_step(technique, acc, deck_size)
    end)
  end

  defp lazy_step(:deal, pos, size) do
    rem(size + size - pos - 1, size)
  end
  defp lazy_step({:deal, inc, deal_map}, target, size) do
    target_rem = rem(inc - rem(target, inc), inc)
    n = Map.fetch!(deal_map, target_rem)
    div(n * size + target, inc)
  end
  defp lazy_step({:cut, n}, pos, size) do
    rem(size + pos + n, size)
  end

  defp prepare_lazy_input([{:deal, inc} | input], deck_size) do
    [{:deal, inc, make_deal_map(inc, deck_size)} |
     prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([technique | input], deck_size) do
    [technique | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([], _), do: []

  defp make_deal_map(inc, deck_size) do
    rem_delta = rem(deck_size, inc)
    make_deal_map(inc, rem_delta, 0, 0, [])
  end

  defp make_deal_map(inc, _rem_delta, _sum, inc, acc) do
    Map.new(acc)
  end
  defp make_deal_map(inc, rem_delta, sum, n, acc) when sum >= inc do
    make_deal_map(inc, rem_delta, rem(sum, inc), n, acc)
  end
  defp make_deal_map(inc, rem_delta, sum, n, acc) do
    make_deal_map(inc, rem_delta, sum + rem_delta, n + 1, [{sum, n} | acc])
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
