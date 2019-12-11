defmodule Aoc7 do
  def load() do
    File.read!("input/7")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def load(program) do
    String.split(program, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def decode(value) do
    digits = Integer.digits(value)
    instruction = case Enum.slice(digits, -2, 2) do
      [] -> digits
      x -> x
    end
    rest = Enum.drop(digits, -2)
    modes = List.duplicate(0, 3 - Enum.count(rest)) ++ rest
    {
      Enum.reduce(
        Enum.with_index(Enum.reverse(modes), 1),
        %{},
        fn {x, i}, acc ->
          mode = case x do
            0 -> :position
            1 -> :immediate
            _ -> throw("Bad addressing mode #{x}")
          end
          Map.put(acc, i, mode)
        end
      ),
      Integer.undigits(instruction)
    }
  end

  def permutations([]), do: [[]] # <-- (!)
  def permutations(list), do: for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]

  def read(mode, program, position) when mode == :position do
    elem(program, elem(program, position))
  end

  def read(mode, program, position) when mode == :immediate do
    elem(program, position)
  end

  def write(mode, program, position, value) when mode == :position do
    put_elem(program, elem(program, position), value)
  end

  def write(mode, _program, _position, _value) when mode == :immediate do
    throw("Can't write immediate.")
  end

  def step({_modes, opcode}, program, input, output, pc) when opcode == 99 do
    {:halt, program, input, output, pc}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 1 do
    left = read(modes[1], program, pc + 1)
    right = read(modes[2], program, pc + 2)
    program = write(modes[3], program, pc + 3, left + right)
    {:continue, program, input, output, pc + 4}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 2 do
    left = read(modes[1], program, pc + 1)
    right = read(modes[2], program, pc + 2)
    program = write(modes[3], program, pc + 3, left * right)
    {:continue, program, input, output, pc + 4}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 3 do
    case input do
      [value | input] ->
        program = write(modes[1], program, pc + 1, value)
        {:continue, program, input, output, pc + 2}
      [] ->
        {:blocked, program, input, output, pc}
    end
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 4 do
    value = read(modes[1], program, pc + 1)
    output = [value | output]
    {:continue, program, input, output, pc + 2, }
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 5 do
    first = read(modes[1], program, pc + 1)
    second = read(modes[2], program, pc + 2)
    if first != 0 do
      {:continue, program, input, output, second}
    else
      {:continue, program, input, output, pc + 3}
    end
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 6 do
    first = read(modes[1], program, pc + 1)
    second = read(modes[2], program, pc + 2)
    if first == 0 do
      {:continue, program, input, output, second}
    else
      {:continue, program, input, output, pc + 3}
    end
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 7 do
    first = read(modes[1], program, pc + 1)
    second = read(modes[2], program, pc + 2)
    program = write(modes[3], program, pc + 3, (if first < second, do: 1, else: 0))
    {:continue, program, input, output, pc + 4}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 8 do
    first = read(modes[1], program, pc + 1)
    second = read(modes[2], program, pc + 2)
    program = write(modes[3], program, pc + 3, (if first == second, do: 1, else: 0))
    {:continue, program, input, output, pc + 4}
  end

  def run(program, input, output, pc \\ 0) do
    instruction = elem(program, pc)
    opcode = decode(instruction)
    case step(opcode, program, input, output, pc) do
      {:halt, program, input, output, pc} -> {:halt, program, input, output, pc}
      {:blocked, program, input, output, pc} -> {:blocked, program, input, output, pc}
      {:continue, program, input, output, pc} -> run(program, input, output, pc)
    end
  end

  def cascade(program, [a, b, c, d, e]) do
    {:halt, program, _, output, _} = Aoc7.run(program, [a, 0], [])
    {:halt, program, _, output, _} = Aoc7.run(program, [b | output], [])
    {:halt, program, _, output, _} = Aoc7.run(program, [c | output], [])
    {:halt, program, _, output, _} = Aoc7.run(program, [d | output], [])
    {:halt, _, _, output, _} = Aoc7.run(program, [e | output], [])
    [answer | _] = output
    answer
  end

  def feedback(program, [a, b, c, d, e]) do
    feedback(
      [
        run(program, [a, 0], []),
        run(program, [b], []),
        run(program, [c], []),
        run(program, [d], []),
        run(program, [e], [])
      ],
      []
    )
  end

  def feedback(thunks, out) when length(thunks) == 1 do
    [{:halt, _, _, output, _}] = thunks
    [output | out] |> List.flatten |> Enum.max
  end

  def feedback([first | thunks], out) do
    case first do
      {:halt, _, _, output, _} ->
        [{:blocked, second_program, _, second_output, second_pc} | thunks] = thunks
        feedback(
          [run(second_program, output, second_output, second_pc) | thunks],
          [output|out]
        )
      {:blocked, first_program, first_input, first_output, first_pc} ->
        [{:blocked, second_program, _, second_output, second_pc} | thunks] = thunks
        feedback(
          [run(second_program, first_output, second_output, second_pc) | thunks] ++ [
            {:blocked, first_program, first_input, [], first_pc}
          ],
          out
        )
    end
  end

  def part1() do
    program = load()
    perms = permutations([0, 1, 2, 3, 4])
    values = Enum.map(
      perms,
      fn guess ->
        cascade(program, guess)
      end
    )
    Enum.max(values)
  end

  def part2() do
    program = load()
    perms = permutations([5, 6, 7, 8, 9])
    values = Enum.map(
      perms,
      fn guess ->
        feedback(program, guess)
      end
    )
    Enum.max(values)
  end
end
