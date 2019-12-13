defmodule Aoc3Test do
  use ExUnit.Case, async: true

  test "part 1" do
    assert Aoc3.part1() == 1017
  end

  test "part 2" do
    assert Aoc3.part2() == 11432
  end

  test "part 1 example 1" do
    {_, _, intersections} = Aoc3.plot_wires(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])

    assert Aoc3.manhatten_distance(intersections) == 159
  end

  test "part 1 example 2" do
    {_, _, intersections} =
      Aoc3.plot_wires([
        "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
        "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
      ])

    assert Aoc3.manhatten_distance(intersections) == 135
  end

  test "part 2 example 1" do
    plan = Aoc3.plot_wires(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])

    assert Aoc3.signal_delay(plan) == 610
  end

  test "part 2 example 2" do
    plan =
      Aoc3.plot_wires([
        "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
        "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
      ])

    assert Aoc3.signal_delay(plan) == 410
  end
end
