defmodule Aoc1Test do
  use ExUnit.Case, async: true

  test "part 1" do
    assert Aoc1.part1() == 3_296_560
  end

  test "part 2" do
    assert Aoc1.part2() == 4_941_976
  end
end
