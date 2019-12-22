defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "part 1 with my examples" do
    assert Day22.part1(example1(), 10) == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]
    assert Day22.part1(example2(), 10) == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]
    assert Day22.part1(example3(), 10) == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
  end

  test "part 1 with my input" do
    assert Day22.part1(input()) == 7096
  end

  test "part 2 with my examples" do
    assert Day22.brute_solve(example4()) ==
      Day22.lazy_solve(example4())
    assert Day22.brute_solve(example5()) ==
      Day22.lazy_solve(example5())
    assert Day22.brute_solve(example3()) ==
      Day22.lazy_solve(example3())
    assert Day22.brute_solve(input(), 10_007, 1) ==
      Day22.lazy_solve(input(), 10_007, 1)
  end

  test "part 2 with my input" do
    assert Day22.part2(input()) == nil
  end

  defp example1() do
    """
    deal with increment 7
    deal into new stack
    deal into new stack
    """
    |> s()
  end

  defp example2() do
    """
    deal with increment 7
    deal with increment 9
    cut -2
    """
    |> s()
  end

  defp example3() do
    """
    deal into new stack
    cut -2
    deal with increment 7
    cut 8
    cut -4
    deal with increment 7
    cut 3
    deal with increment 9
    deal with increment 3
    cut -1
    """
    |> s()
  end

  defp example4() do
    """
    deal into new stack
    cut -2
    deal into new stack
    cut 8
    cut -4
    deal into new stack
    cut 333
    cut -199
    deal into new stack
    cut 8
    """
    |> s()
  end

  defp example5() do
    """
    deal with increment 3
    """
    |> s()
  end

  defp input do
    File.read!('input.txt')
    |> String.trim
    |> String.split("\n")
  end

  defp s(string) do
    string
    |> String.trim
    |> String.split("\n")
  end
end
