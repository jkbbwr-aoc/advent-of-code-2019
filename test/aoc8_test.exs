defmodule Aoc8Test do
  use ExUnit.Case, async: true

  test "part 1 example 1" do
    digits = Aoc8.load("123456789012")
    assert Aoc8.build(digits, 3, 2) == [[1, 2, 3, 4, 5, 6], [7, 8, 9, 0, 1, 2]]
  end

  test "part 1" do
    assert Aoc8.part1() == 2032
  end

  test "part 2 example 1" do
    digits = Aoc8.load("0222112222120000")
             |> Aoc8.build(2, 2)
    Aoc8.draw("output/test.png", digits, 2, 2)
    IO.puts("You need to check output/test.png looks like a chessboard.")
    assert true
  end

  test "part 2" do
    Aoc8.part2()
    IO.puts("You need to check output/8.png reads C F C U G")
    assert true
  end
end
