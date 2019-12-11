defmodule Aoc9Test do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @part2_answer """
  █████████████████████████████████████████
  █   ████  █   ██ ██ █ ██████  █ ██ █   ██
  █ ██ ████ █ ██ █ █ ██ ███████ █ ██ █ ██ █
  █   █████ █ ██ █  ███ ███████ █ ██ █ ██ █
  █ ██ ████ █   ██ █ ██ ███████ █ ██ █   ██
  █ ██ █ ██ █ █ ██ █ ██ ████ ██ █ ██ █ ████
  █   ███  ██ ██ █ ██ █    ██  ███  ██ ████
  █████████████████████████████████████████
  """

  test "part 1 example 1" do
    {pos, direction} = Aoc11.transform({0, 0}, :up, 0)
    {pos, direction} = Aoc11.transform(pos, direction, 0)
    {pos, direction} = Aoc11.transform(pos, direction, 0)
    {pos, direction} = Aoc11.transform(pos, direction, 0)
    assert pos == {0, 0}
    assert direction == :up
  end

  test "part 1 example 2" do
    {pos, direction} = Aoc11.transform({0, 0}, :up, 1)
    {pos, direction} = Aoc11.transform(pos, direction, 1)
    {pos, direction} = Aoc11.transform(pos, direction, 1)
    {pos, direction} = Aoc11.transform(pos, direction, 1)
    assert pos == {0, 0}
    assert direction == :up
  end

  test "part 1" do
    assert Aoc11.part1() == 2093
  end

  test "part 2" do
    assert capture_io(&Aoc11.part2/0) == @part2_answer
  end
end
