defmodule Aoc3 do
  def load() do
    File.read!("input/3")
    |> String.split("\n")
  end

  def parse(instruction) do
    direction = String.first(instruction)
    {distance, ""} = Integer.parse(String.slice(instruction, 1..-1))

    case direction do
      "R" -> {:right, distance}
      "L" -> {:left, distance}
      "U" -> {:up, distance}
      "D" -> {:down, distance}
    end
  end

  def plot_wire(instructions) do
    Enum.reduce(
      instructions,
      [{0, 0}],
      fn v, acc ->
        [h | _] = acc
        {x, y} = h
        {direction, distance} = v

        {point, rest} =
          case direction do
            :up -> {{x, y + distance}, for(i <- y..(y + distance), do: {x, i})}
            :down -> {{x, y - distance}, for(i <- y..(y - distance), do: {x, i})}
            :left -> {{x - distance, y}, for(i <- x..(x - distance), do: {i, y})}
            :right -> {{x + distance, y}, for(i <- x..(x + distance), do: {i, y})}
          end

        [point | Enum.reverse(rest)] ++ acc
      end
    )
  end

  def plot_wires(wires) do
    [line1, line2] = wires

    wire1 =
      line1
      |> String.split(",")
      |> Enum.map(&parse/1)
      |> plot_wire

    wire2 =
      line2
      |> String.split(",")
      |> Enum.map(&parse/1)
      |> plot_wire

    {
      wire1,
      wire2,
      MapSet.intersection(
        MapSet.new(wire1)
        |> MapSet.delete({0, 0}),
        MapSet.new(wire2)
      )
    }
  end

  def manhatten_distance(plan) do
    plan
    |> Enum.reject(fn {x, y} -> x == 0 && y == 0 end)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def signal_delay(plan) do
    {wire1, wire2, intersection} = plan

    wire1 =
      Enum.reverse(wire1)
      |> Enum.dedup()

    wire2 =
      Enum.reverse(wire2)
      |> Enum.dedup()

    Enum.map(
      intersection,
      fn x ->
        {Enum.find_index(wire1, fn y -> x == y end), Enum.find_index(wire2, fn y -> x == y end)}
      end
    )
    |> Enum.map(fn {x, y} -> x + y end)
    |> Enum.min()
  end

  def part1() do
    {_, _, intersection} = plot_wires(load())
    manhatten_distance(intersection)
  end

  def part2() do
    plan = plot_wires(load())
    signal_delay(plan)
  end
end
