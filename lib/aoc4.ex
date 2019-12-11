defmodule Aoc4 do
  require Integer

  def load() do
    [start, stop] =
      File.read!("input/4")
      |> String.trim()
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    Range.new(start, stop)
  end

  def adjacency_part2(digits) do
    counts = Enum.reduce(digits, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    case Enum.member?(Map.values(counts), 2) do
      true -> Enum.any?(counts, fn {_, v} -> v == 1 || Integer.mod(v, 2) end)
      false -> false
    end
  end

  def verify(number) do
    digits = Integer.digits(number)
    # has two adjacent digits
    adjacent =
      digits
      |> Enum.dedup()
      |> Enum.count() != Enum.count(digits)

    # Each digit is greater than the previous
    greater =
      Enum.reduce_while(
        digits,
        [],
        fn x, acc ->
          head =
            case acc do
              [head | _] -> head
              [] -> 0
            end

          case x >= head do
            true -> {:cont, [x | acc]}
            false -> {:halt, false}
          end
        end
      )

    greater && adjacent
  end

  def part1() do
    range = load()

    Enum.filter(
      range,
      fn x ->
        verify(x)
      end
    )
    |> Enum.count()
  end

  def part2() do
    range = load()

    part1_filtered =
      Enum.filter(
        range,
        fn x ->
          verify(x)
        end
      )

    Enum.filter(
      part1_filtered,
      fn x ->
        adjacency_part2(Integer.digits(x))
      end
    )
    |> Enum.count()
  end
end
