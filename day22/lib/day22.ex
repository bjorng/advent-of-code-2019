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
#    positive_rem(next + times * (next - @part2_position), deck_size)
  end

  defp positive_rem(n, s) do
    case rem(n, s) do
      r when r < 0 -> positive_rem(n + s, s)
      r -> r
    end
  end

  defp lazy_stream(input, deck_size, target) do
    input = parse_input(input)
    input = Enum.reverse(input)
    Stream.iterate(target, & next_lazy(input, deck_size, &1))
  end

  defp next_lazy(input, deck_size, target) do
    Enum.reduce(input, target, fn technique, acc ->
      lazy_step(technique, acc, deck_size)
    end)
  end

  defp lazy_step(:deal, pos, size) do
    size - pos - 1
  end
  defp lazy_step({:deal, inc}, target_pos, size) do
    backward_deal(target_pos, inc, size)
  end
  defp lazy_step({:cut, n}, pos, size) do
    pos + n
  end

  defp backward_deal(target, inc, size) do
    rem_delta = rem(size, inc)
    n = backward_deal(rem(inc - rem(target, inc), inc), inc, rem_delta, 0, 0)
    div(n * size + target, inc)
  end

  defp backward_deal(target_rem, inc, rem_delta, sum, n) when sum >= inc do
    backward_deal(target_rem, inc, rem_delta, rem(sum, inc), n)
  end
  defp backward_deal(target_rem, inc, rem_delta, sum, n) do
    if sum === target_rem do
      n
    else
      backward_deal(target_rem, inc, rem_delta, sum + rem_delta, n + 1)
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
