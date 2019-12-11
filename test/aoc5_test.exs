defmodule Aoc5Test do
  use ExUnit.Case, async: true

  test "part 1" do
    assert Aoc5.part1() == 13978427
  end

  test "part 2" do
    assert Aoc5.part2() == 11189491
  end

  test "part 1 example 1" do
    program = Aoc5.load("1002,4,3,4,33")
    {:halt, program, _input, _output, _pc} = Aoc5.run(program, [], [])
    assert program == {1002, 4, 3, 4, 99}
  end

  test "part 2 example 1 (using position mode)" do
    program = Aoc5.load("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9")
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [0], [])
    assert Enum.at(output, 0) == 0
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [55], [])
    assert Enum.at(output, 0) == 1
  end

  test "part 2 example 2 (using immediate mode)" do
    program = Aoc5.load("3,3,1105,-1,9,1101,0,0,12,4,12,99,1")
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [0], [])
    assert Enum.at(output, 0) == 0
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [55], [])
    assert Enum.at(output, 0) == 1
  end

  test "part 2 example 3" do
    program = Aoc5.load(
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
    )
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [7], [])
    assert Enum.at(output, 0) == 999
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [8], [])
    assert Enum.at(output, 0) == 1000
    {:halt, _program, _input, output, _pc} = Aoc5.run(program, [9], [])
    assert Enum.at(output, 0) == 1001
  end
end
