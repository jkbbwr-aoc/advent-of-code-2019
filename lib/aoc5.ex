defmodule Aoc5 do
  def load() do
    File.read!("input/5")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def load(program) do
    String.split(program, ",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def decode(value) do
    digits = Integer.digits(value)

    instruction =
      case Enum.slice(digits, -2, 2) do
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
          mode =
            case x do
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
    [value | input] = input
    program = write(modes[1], program, pc + 1, value)
    {:continue, program, input, output, pc + 2}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 4 do
    value = read(modes[1], program, pc + 1)
    output = [value | output]
    {:continue, program, input, output, pc + 2}
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
    program = write(modes[3], program, pc + 3, if(first < second, do: 1, else: 0))
    {:continue, program, input, output, pc + 4}
  end

  def step({modes, opcode}, program, input, output, pc) when opcode == 8 do
    first = read(modes[1], program, pc + 1)
    second = read(modes[2], program, pc + 2)
    program = write(modes[3], program, pc + 3, if(first == second, do: 1, else: 0))
    {:continue, program, input, output, pc + 4}
  end

  def run(program, input, output, pc \\ 0) do
    instruction = elem(program, pc)
    opcode = decode(instruction)

    case step(opcode, program, input, output, pc) do
      {:halt, program, input, output, pc} -> {:halt, program, input, output, pc}
      {:continue, program, input, output, pc} -> run(program, input, output, pc)
    end
  end

  def part1() do
    program = Aoc5.load()
    {:halt, _program, _input, output, _pc} = run(program, [1], [])
    Enum.at(output, 0)
  end

  def part2() do
    program = Aoc5.load()
    {:halt, _program, _input, output, _pc} = run(program, [5], [])
    Enum.at(output, 0)
  end
end
