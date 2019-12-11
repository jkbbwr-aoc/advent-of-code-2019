defmodule Aoc9Test do
  use ExUnit.Case, async: true

  test "part 1 example 1" do
    program = Aoc9.load("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
    {:halt, _program, _input, output, _pc, _rp} = Aoc9.run(program, [], [])
    assert output == [99, 0, 101, 1006, 101, 16, 100, 1008, 100, 1, 100, 1001, -1, 204, 1, 109]
  end

  test "part 1 example 2" do
    program = Aoc9.load("1102,34915192,34915192,7,4,7,99,0")
    {:halt, _program, _input, [output], _pc, _rp} = Aoc9.run(program, [], [])
    assert output == 1219070632396864
  end

  test "part 1 example 3" do
    program = Aoc9.load("104,1125899906842624,99")
    {:halt, _program, _input, [output], _pc, _rp} = Aoc9.run(program, [], [])
    assert output == 1125899906842624
  end

  test "part 1" do
    assert Aoc9.part1() == 3497884671
  end

  test "part 2" do
    assert Aoc9.part2() == 46470
  end
end
