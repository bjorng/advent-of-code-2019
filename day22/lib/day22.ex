defmodule Day22 do
  use Bitwise

  def part1(input, deck_size \\ 10_007) do
    input = parse_input(input)
    deck = 0..deck_size-1 |> Enum.to_list
    deck = Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc, deck_size)
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
    lazy_solve(input, deck_size, times)
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
    Stream.iterate(deck, & next_brute(input, &1, deck_size))
  end

  defp next_brute(input, deck, deck_size) do
    Enum.reduce(input, deck, fn technique, acc ->
      one_step(technique, acc, deck_size)
    end)
  end

  def test_input(input) do
    deck_size = 10_007
    input = parse_input(input)
    input = Enum.reverse(input)
    input = prepare_lazy_input(input, deck_size)
    zero = solve_one(input, deck_size, 0)
    next = solve_one(input, deck_size, zero)
    IO.inspect {zero, next}
  end

  def lazy_solve(input, deck_size \\ 10_007,
    times \\ 1, target \\ @part2_position) do
    input = parse_input(input)
    input = Enum.reverse(input)
    input = prepare_lazy_input(input, deck_size)
    zero = solve_one(input, deck_size, 0)
    one = solve_one(input, deck_size, 1)
    diff = positive_rem(one - zero, deck_size)
    target = do_lazy_solve10(target, zero, diff, deck_size, div(times, 10))
    do_lazy_solve(target, zero, diff, deck_size, rem(times, 10))
  end

  defp do_lazy_solve(target, _, _, _, 0), do: target
  defp do_lazy_solve(target, zero, diff, deck_size, times) do
    target = rem(zero + diff * target, deck_size)
    do_lazy_solve(target, zero, diff, deck_size, times - 1)
  end

  defp do_lazy_solve10(target, _, _, _, 0), do: target
  defp do_lazy_solve10(target, zero, diff, deck_size, times) do
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = zero + diff * target
    target = rem(target, deck_size)
    do_lazy_solve10(target, zero, diff, deck_size, times - 1)
  end

  # def lazy_solve(input, deck_size \\ 10_007,
  #   times \\ 1, target \\ @part2_position) do
  #   input = parse_input(input)
  #   input = Enum.reverse(input)
  #   input = prepare_lazy_input(input, deck_size)
  #   zero = solve_one(input, deck_size, 0)
  #   one = solve_one(input, deck_size, 1)
  #   diff = positive_rem(one - zero, deck_size)
  #   rem(do_lazy_solve(zero, zero, diff, deck_size, times - 1) +
  #     mod_int_pow(diff, times, deck_size) * target, deck_size)
  # end

  # defp do_lazy_solve(prev, _, _, _, 0), do: prev
  # defp do_lazy_solve(prev, zero, diff, deck_size, times) do
  #   if rem(times, 10_000_000) === 0 do
  #     IO.inspect(times)
  #   end
  #   prev = rem(zero + diff * prev, deck_size)
  #   do_lazy_solve(prev, zero, diff, deck_size, times - 1)
  # end

  # @doc """
  # Raise an integer to a power with modulus.

  # ## Examples:

  #     iex> Day22.mod_int_pow(7, 2, 10)
  #     9
  #     iex> Day22.mod_int_pow(7, 3, 10)
  #     3
  #     iex> Day22.mod_int_pow(7, 5, 13)
  #     11
  #     iex> Day22.mod_int_pow(53, 13, 777)
  #     305
  # """
  # def mod_int_pow(x, p, m, res \\ 1)
  # def mod_int_pow(_, 0, _, res), do: res
  # def mod_int_pow(x, p, m, res) do
  #   next_x = x * x
  #   next_p = bsr(p, 1)
  #   case band(p, 1) do
  #     0 ->
  #       mod_int_pow(next_x, next_p, m, rem(res, m))
  #     1 ->
  #       mod_int_pow(next_x, next_p, m, rem(res*x, m))
  #   end
  # end

  defp positive_rem(n, deck_size) do
    n = rem(n, deck_size)
    if n < 0, do: positive_rem(n + deck_size, deck_size), else: n
  end

  defp lazy_stream(input, deck_size, target) do
    input = parse_input(input)
    input = Enum.reverse(input)
    input = prepare_lazy_input(input, deck_size)
    Stream.iterate(target, & next_lazy(input, deck_size, &1))
  end

  defp next_lazy(input, deck_size, target) do
    zero = solve_one(input, deck_size, 0)
    one = solve_one(input, deck_size, 1)
    diff = positive_rem(one - zero, deck_size)
    rem(zero + diff * target, deck_size)
  end

  defp solve_one(input, deck_size, target) do
    Enum.reduce(input, target, fn technique, acc ->
      lazy_step(technique, acc, deck_size)
    end)
  end

  defp next_lazy_blurf(input, deck_size, target) do
    Enum.reduce(input, target, fn technique, acc ->
      lazy_step(technique, acc, deck_size)
    end)
  end

  defp lazy_step({:cut_deal, n}, pos, size) do
    rem(size + n - pos, size)
  end
  defp lazy_step({:cut, n}, pos, size) do
    rem(size + pos + n, size)
  end
  defp lazy_step({:deal, inc, deal_map}, target, size) do
    target_rem = rem(inc - rem(target, inc), inc)
    n = Map.fetch!(deal_map, target_rem)
    div(n * size + target, inc)
  end

  defp prepare_lazy_input([{:cut, n}, :deal | input], deck_size) do
    [{:cut_deal, -n - 1} | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([:deal, {:cut, n} | input], deck_size) do
    [{:cut_deal, n - 1} | prepare_lazy_input(input, deck_size)]
  end
  defp prepare_lazy_input([:deal | input], deck_size) do
    [{:cut_deal, -1} | prepare_lazy_input(input, deck_size)]
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

  defp one_step(:deal, deck, _deck_size) do
    Enum.reverse(deck)
  end
  defp one_step({:deal, inc}, deck, deck_size) do
    {numbered, _} = Enum.map_reduce(deck, 0, fn card, index ->
      {{rem(index, deck_size), card}, index + inc}
    end)
    Enum.sort(numbered) |> Enum.map(fn {_, card} -> card end)
  end
  defp one_step({:cut, n}, deck, deck_size) do
    if n < 0 do
      {first, rest} = Enum.split(deck, deck_size + n)
      rest ++ first
    else
      {first, rest} = Enum.split(deck, n)
      rest ++ first
    end
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

  # def test(input) do
  #   [5023, 5039, 5051, 5059, 5077, 5081, 10007]
  #   |> Enum.each(fn deck_size ->
  #     same = 0..deck_size - 1
  #     |> Enum.map(& lazy_solve(input, deck_size, 1, &1))
  #     |> Stream.with_index
  #     |> Enum.find_value(fn
  #       {a, a} -> a
  #       {_, _} -> nil
  #     end)
  #     same-2..same+2
  #     |> Enum.map(fn target ->
  #       IO.inspect({deck_size, target, lazy_solve(input, deck_size, 1, target)})
  #     end)
  #   end)
  # end

  # def test(input) do
  #   deck_size = 5059
  #   IO.inspect({lazy_solve(input, deck_size, 1, 4029),
  #               lazy_solve(input, deck_size, 1, 4030),
  #               lazy_solve(input, deck_size, 1, 4031),
  #               lazy_solve(input, deck_size, 1, 4032),
  #               lazy_solve(input, deck_size, 1, 4033)})
  #   [{x, _}] = 0..deck_size - 1
  #   |> Enum.map(& lazy_solve(input, deck_size, 1, &1))
  #   |> Stream.with_index
  #   |> Enum.filter(fn {a, b} -> a == b end)
  #   IO.inspect({deck_size,x,find_cycle(input, deck_size)})
  # end

  # def test(input) do
  #   deck_size = 5059
  #   [{x, _}] = 0..deck_size - 1
  #   |> Enum.map(& lazy_solve(input, deck_size, 1, &1))
  #   |> Stream.with_index
  #   |> Enum.filter(fn {a, b} -> a == b end)
  #   IO.inspect({deck_size,x,find_cycle(input, deck_size)})
  # end

  def test(input) do
    deck_size = 119_315_717_514_047
    times = 101_741_582_076_661
    #        42_083_723_319_638
    #    deck_size = 10007
    # 0..deck_size - 1
    # |> Enum.map(& lazy_solve(input, deck_size, 1, &1))
    # |> Enum.reduce(0, fn n, prev ->n
    #   IO.inspect({n, positive_rem(n - prev, deck_size)})
    #   n
    # end)
    # IO.write "\n"
    # Stream.iterate(0, & rem(&1 + 634, 5059))
    # |> Stream.drop(1)
    # |> Enum.find_index(& &1 === 0)
    # |> IO.inspect
    p = div(deck_size - 1, 2)
    IO.inspect p
    IO.inspect {div(times, p), rem(times, p)}
    lazy_solve(input, deck_size, 1) |> IO.inspect
#    lazy_solve(input, deck_size, p + 1) |> IO.inspect
  end

  def find_cycles(input) do
    [5023, 5039, 5051, 5059, 5077, 5081, 10007, 30851, 66383, 66403, 66413, 66431, 66449, 72019, 104711, 104717, 104723, 119_315_717_514_047]
    |> Enum.each(fn prime ->
      IO.inspect {prime, find_cycle(input, prime)}
    end)
  end

  def find_cycle(input, deck_size) do
    target = @part2_position
    input = parse_input(input)
    input = Enum.reverse(input)
    input = prepare_lazy_input(input, deck_size)
    zero = solve_one(input, deck_size, 0)
    one = solve_one(input, deck_size, 1)
    diff = positive_rem(one - zero, deck_size)
    next = rem(zero + diff * target, deck_size)
    IO.inspect({zero, diff, next})
    do_find_cycle(next, zero, diff, deck_size, target, 0)
  end

  defp do_find_cycle(target, _, _, _, target, n), do: n
  defp do_find_cycle(next, zero, diff, deck_size, rep, n) do
    next = rem(zero + diff * next, deck_size)
    do_find_cycle(next, zero, diff, deck_size, rep, n + 1)
  end

  # def find_cycle(input, deck_size, target \\ @part2_position) do
  #   lazy_stream(input, deck_size, target)
  #   |> Stream.drop(1)
  #   |> Enum.find_index(& &1 === target)
  # end

end
