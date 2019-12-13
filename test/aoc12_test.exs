defmodule Aoc12Test do
  use ExUnit.Case, async: true

  @pos1 """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
  """

  @pos2 """
    <x=-8, y=-10, z=0>
    <x=5, y=5, z=10>
    <x=2, y=-7, z=3>
    <x=9, y=-8, z=-3>
  """

  test "part 1 example 1" do
    results = [
      %Aoc12.Moon{x: 2, y: 1, z: -3, vx: -3, vy: -2, vz: 1},
      %Aoc12.Moon{x: 1, y: -8, z: 0, vx: -1, vy: 1, vz: 3},
      %Aoc12.Moon{x: 3, y: -6, z: 1, vx: 3, vy: 2, vz: -3},
      %Aoc12.Moon{x: 2, y: 0, z: 4, vx: 1, vy: -1, vz: -1}
    ]
    assert Aoc12.simulate(Aoc12.load(@pos1), 10) == results
  end

  test "part 1" do
    assert Aoc12.part1() == 9127
  end

  test "part 2 exercise 1" do
    assert Aoc12.universe(Aoc12.load(@pos2)) == 4686774924
  end

  test "part 2" do
    assert Aoc12.part2() == 353620566035124
  end
end
