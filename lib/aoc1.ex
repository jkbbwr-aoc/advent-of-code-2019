defmodule Aoc1 do
  def fuel_for(fuel, carry \\ 0)
  def fuel_for(fuel, carry) when fuel >= 0 do
    new = floor(fuel / 3) - 2
    if new <= 0 do
      fuel_for(new, carry)
    else
      fuel_for(new, carry + new)
    end
  end
  def fuel_for(_, carry) do
    carry
  end

  def solve_part(f) do
    File.read!("input/1")
    |> String.split("\n")
    |> Enum.reject(fn i -> i == "" end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(f)
    |> Enum.sum
  end

  def part1() do
    solve_part(fn fuel -> floor(fuel / 3) - 2 end)
  end

  def part2() do
    solve_part(&fuel_for/1)
  end
end