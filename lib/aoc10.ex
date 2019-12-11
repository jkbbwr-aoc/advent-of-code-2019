defmodule Aoc10 do
  defmodule Rock do
    defstruct [:x, :y, :distance, :angle]
  end

  def load() do
    File.read!("input/10")
    |> String.split("\n")
    |> Enum.map(fn x -> Enum.with_index(String.graphemes(x))end)
    |> Enum.with_index
  end

  def load(map) do
    map
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> Enum.with_index(String.graphemes(x))end)
    |> Enum.with_index
  end

  def build_grid(input) do
    Enum.reduce(
      input,
      %{},
      fn {line, row}, acc ->
        Enum.reduce(
          line,
          acc,
          fn {point, col}, acc ->
            Map.put(acc, {col, row}, point)
          end
        )
      end
    )
  end

  def distance(x1, y1, x2, y2) do
    dx = x1 - x2
    dy = y1 - y2
    :math.sqrt(dx * dx + dy * dy)
  end

  def reduce_los({_x1, _y1}, [], los) do
    los
  end

  def reduce_los({x1, y1}, rocks, los) do
    [{x2, y2} | rocks] = rocks
    angle = :math.atan2(y1 - y2, x1 - x2)
    rock = %Rock{
      x: x2,
      y: y2,
      angle: angle,
      distance: distance(x1, y1, x2, y2)
    }
    los = Map.put_new(los, {x1, y1}, [])
    {_, los} = Map.get_and_update(
      los,
      {x1, y1},
      fn current_value ->
        {
          current_value,
          [rock | current_value]
          |> Enum.sort_by(fn value -> value.distance end)
        }
      end
    )
    reduce_los({x1, y1}, rocks, los)
  end

  def solve_for_los(grid) do
    rocks = Enum.reduce(grid, [], fn {cord, char}, acc -> if char == "#", do: [cord | acc], else: acc end)
    Enum.map(
      rocks,
      fn rock ->
        reduce_los(rock, Enum.filter(rocks, &(&1 != rock)), %{})
      end
    )
  end

  def part1() do
    map = Aoc10.load()
    grid = Aoc10.build_grid(map)
    score = Aoc10.solve_for_los(grid)
    target = Enum.max_by(
      score,
      fn rock ->
        Map.values(rock)
        |> Enum.at(0)
        |> MapSet.new(fn rock -> rock.angle end)
        |> Enum.count()
      end
    )
    Map.keys(target)
    |> Enum.at(0)
  end

  def part2(map) do
    map = Aoc10.load(map)
    grid = Aoc10.build_grid(map)
    score = Aoc10.solve_for_los(grid)
    Enum.max_by(
      score,
      fn rock ->
        Map.values(rock)
        |> Enum.at(0)
        |> MapSet.new(fn rock -> rock.angle end)
        |> Enum.count()
      end
    )
  end
end