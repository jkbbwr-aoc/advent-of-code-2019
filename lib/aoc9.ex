defmodule Aoc9 do
  require Logger

  def load() do
    File.read!("input/9")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def load(program) do
    String.split(program, ",")
    |> Enum.map(&String.to_integer/1)
  end

  def debug({modes, opcode}, pc, rp) do
    Logger.debug("INSTR: #{opcode} PC: #{pc} RP: #{rp} MODES: #{inspect modes}")
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
            2 -> :relative
            _ -> throw("Bad addressing mode #{x}")
          end
          Map.put(acc, i, mode)
        end
      ),
      Integer.undigits(instruction)
    }
  end

  def read(mode, program, position, _relative) when mode == :position do
    position = Enum.at(program, position)
    if position >= Enum.count(program) do
      0
    else
      Enum.at(program, position)
    end
  end

  def read(mode, program, position, relative) when mode == :relative do
    position = Enum.at(program, position) + relative
    if position >= Enum.count(program) do
      0
    else
      Enum.at(program, position)
    end
  end

  def read(mode, program, position, _relative) when mode == :immediate do
    position = position
    if position >= Enum.count(program) do
      0
    else
      Enum.at(program, position)
    end
  end

  def write(mode, program, position, value, _relative) when mode == :position do
    target = Enum.at(program, position)
    program = if target > Enum.count(program) do
      program ++ List.duplicate(0, target)
    else
      program
    end
    List.replace_at(program, target, value)
  end

  def write(mode, program, position, value, relative) when mode == :relative do
    program = if position > Enum.count(program) do
      program ++ List.duplicate(0, position)
    else
      program
    end
    position = Enum.at(program, position) + relative
    List.replace_at(program, position, value)
  end

  def write(mode, _program, _position, _value, _relative) when mode == :immediate do
    throw("Can't write immediate.")
  end

  def write_directly(program, position, value) do
    List.replace_at(program, position, value)
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 1 do
    left = read(modes[1], program, pc + 1, rp)
    right = read(modes[2], program, pc + 2, rp)
    program = write(modes[3], program, pc + 3, left + right, rp)
    {:continue, program, input, output, pc + 4, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 2 do
    left = read(modes[1], program, pc + 1, rp)
    right = read(modes[2], program, pc + 2, rp)
    program = write(modes[3], program, pc + 3, left * right, rp)
    {:continue, program, input, output, pc + 4, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 3 do
    case input do
      [value | input] ->
        program = write(modes[1], program, pc + 1, value, rp)
        {:continue, program, input, output, pc + 2, rp}
      [] ->
        {:blocked, program, input, output, pc, rp}
    end
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 4 do
    value = read(modes[1], program, pc + 1, rp)
    output = [value | output]
    {:continue, program, input, output, pc + 2, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 5 do
    first = read(modes[1], program, pc + 1, rp)
    second = read(modes[2], program, pc + 2, rp)
    if first != 0 do
      {:continue, program, input, output, second, rp}
    else
      {:continue, program, input, output, pc + 3, rp}
    end
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 6 do
    first = read(modes[1], program, pc + 1, rp)
    second = read(modes[2], program, pc + 2, rp)
    if first == 0 do
      {:continue, program, input, output, second, rp}
    else
      {:continue, program, input, output, pc + 3, rp}
    end
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 7 do
    first = read(modes[1], program, pc + 1, rp)
    second = read(modes[2], program, pc + 2, rp)
    value = (if first < second, do: 1, else: 0)
    program = write(modes[3], program, pc + 3, value, rp)
    {:continue, program, input, output, pc + 4, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 8 do
    first = read(modes[1], program, pc + 1, rp)
    second = read(modes[2], program, pc + 2, rp)
    value = (if first == second, do: 1, else: 0)
    program = write(modes[3], program, pc + 3, value, rp)
    {:continue, program, input, output, pc + 4, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 9 do
    first = read(modes[1], program, pc + 1, rp)
    {:continue, program, input, output, pc + 2, rp + first}
  end

  def step({_modes, opcode}, program, input, output, pc, rp) when opcode == 99 do
    {:halt, program, input, output, pc, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) do
    raise "\nInvalid opcode #{opcode}
    PC: #{pc}\t RP: #{rp}
    Program: #{inspect Enum.slice(program, pc..pc + 3)}
    Modes: #{inspect modes}
    Input: #{inspect input}
    Output: #{inspect output}"
  end

  def run(program, input, output, pc \\ 0, rp \\ 0) do
    instruction = Enum.at(program, pc)
    opcode = decode(instruction)
    case step(opcode, program, input, output, pc, rp) do
      {:halt, program, input, output, pc, rp} -> {:halt, program, input, output, pc, rp}
      {:blocked, program, input, output, pc, rp} -> {:blocked, program, input, output, pc, rp}
      {:continue, program, input, output, pc, rp} -> run(program, input, output, pc, rp)
    end
  end

  def part1() do
    program = Aoc9.load()
    {:halt, _program, _input, [output], _pc, _rp} = Aoc9.run(program, [1], [])
    output
  end

  def part2() do
    program = Aoc9.load()
    {:halt, _program, _input, [output], _pc, _rp} = Aoc9.run(program, [2], [])
    output
  end
end
