defmodule Aoc2Test do
  use ExUnit.Case, async: true

  test "part 1" do
    assert Aoc2.part1() == 7_210_630
  end

  test "part 2" do
    assert Aoc2.part2() == 3892
  end
end
