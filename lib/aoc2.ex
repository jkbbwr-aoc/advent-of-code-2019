defmodule Aoc2 do
  def load() do
    File.read!("input/2")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def narg3(program, pc) do
    {
      elem(program, elem(program, pc + 1)),
      elem(program, elem(program, pc + 2)),
      elem(program, pc + 3)
    }
  end

  def step(program, pc) when elem(program, pc) == 99 do
    {:halt, program, pc}
  end

  def step(program, pc) when elem(program, pc) == 1 do
    {left, right, out} = narg3(program, pc)
    {:continue, put_elem(program, out, left + right), 4}
  end

  def step(program, pc) when elem(program, pc) == 2 do
    {left, right, out} = narg3(program, pc)
    {:continue, put_elem(program, out, left * right), 4}
  end

  def step(program, pc) do
    {:crash, program, pc}
  end

  def run(program, pc \\ 0) do
    case step(program, pc) do
      {:continue, new_program, step} -> run(new_program, pc + step)
      stop -> stop
    end
  end

  def hack(program, noun \\ 12, verb \\ 2) do
    put_elem(program, 1, noun)
    |> put_elem(2, verb)
  end

  def part2() do
    goal = 19690720
    r = Enum.find_value(
      0..100,
      fn n ->
        v = Enum.find(
          0..100,
          fn v ->
            result = load()
                     |> hack(n, v)
                     |> run()
                     |> elem(1)
                     |> elem(0)
            result == goal
          end
        )
        v != nil && {n, v}
      end
    )
    100 * elem(r, 0) + elem(r, 1)
  end

  def part1() do
    {:halt, program, _} = load()
                          |> hack()
                          |> run()
    program
    |> elem(0)
  end
end
