defmodule Aoc6Test do
  use ExUnit.Case, async: true

  test "part 1 example 1" do
    a = "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L"
    links = Aoc6.load(a)
    total = Aoc6.distance_from_com(links)
    assert total == 42
  end

  test "part 1" do
    assert Aoc6.part1() == 251_208
  end

  test "part 2 example 1" do
    a = "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN"
    links = Aoc6.load(a)
    assert Aoc6.route(links) == 4
  end

  test "part 2" do
    assert Aoc6.part2() == 397
  end
end
