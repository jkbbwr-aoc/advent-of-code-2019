defmodule Aoc16Test do
  use ExUnit.Case, async: true

  test "test part 1 example 1" do
    a = Aoc16.fft_step("12345678")
    assert a == [4, 8, 2, 2, 6, 1, 5, 8]
    a = Aoc16.fft_step(a)
    assert a == [3, 4, 0, 4, 0, 4, 3, 8]
    a = Aoc16.fft_step(a)
    assert a == [0, 3, 4, 1, 5, 5, 1, 8]
    a = Aoc16.fft_step(a)
    assert a == [0, 1, 0, 2, 9, 4, 9, 8]
  end

  test "test part 1 example 2" do
    assert Aoc16.fft("80871224585914546619083218645595", 100) == "24176176"
  end

  test "test part 1 example 3" do
    assert Aoc16.fft("19617804207202209144916044189917", 100) == "73745418"
  end

  test "test part 1 example 4" do
    assert Aoc16.fft("69317163492948606335995924319873", 100) == "52432133"
  end

  test "part 1" do
    assert Aoc16.part1() == "10332447"
  end

  test "part 2" do
    assert Aoc16.part2() == 14_288_025
  end
end
