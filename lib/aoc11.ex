defmodule Aoc11 do
  require Logger

  def load() do
    File.read!("input/11")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def load(program) do
    String.split(program, ",")
    |> Enum.map(&String.to_integer/1)
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

    program =
      if target > Enum.count(program) do
        program ++ List.duplicate(0, target)
      else
        program
      end

    List.replace_at(program, target, value)
  end

  def write(mode, program, position, value, relative) when mode == :relative do
    position = Enum.at(program, position) + relative

    program =
      if position > Enum.count(program) do
        program ++ List.duplicate(0, position)
      else
        program
      end

    List.replace_at(program, position, value)
  end

  def write(mode, _program, _position, _value, _relative) when mode == :immediate do
    throw("Can't write immediate.")
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
    value = if first < second, do: 1, else: 0
    program = write(modes[3], program, pc + 3, value, rp)
    {:continue, program, input, output, pc + 4, rp}
  end

  def step({modes, opcode}, program, input, output, pc, rp) when opcode == 8 do
    first = read(modes[1], program, pc + 1, rp)
    second = read(modes[2], program, pc + 2, rp)
    value = if first == second, do: 1, else: 0
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
    Program: #{inspect(Enum.slice(program, pc..(pc + 3)))}
    Modes: #{inspect(modes)}
    Input: #{inspect(input)}
    Output: #{inspect(output)}"
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

  defmodule Panel do
    defstruct color: :black, painted: false
  end

  def from_color(:white), do: 1
  def from_color(:black), do: 0
  def to_color(0), do: :black
  def to_color(1), do: :white

  # Left
  def transform(pos, facing, 0) do
    {x, y} = pos

    case facing do
      # If I am facing up, I will turn left
      # Then move 1 square forward.
      :up -> {{x - 1, y}, :left}
      :left -> {{x, y - 1}, :down}
      :down -> {{x + 1, y}, :right}
      :right -> {{x, y + 1}, :up}
    end
  end

  # Right
  def transform(pos, facing, 1) do
    {x, y} = pos

    case facing do
      :up -> {{x + 1, y}, :right}
      :right -> {{x, y - 1}, :down}
      :down -> {{x - 1, y}, :left}
      :left -> {{x, y + 1}, :up}
    end
  end

  def do_the_robot(output, pos, facing, grid) do
    panel = grid[pos]
    [direction, code] = output
    panel = %{panel | color: to_color(code), painted: true}

    grid =
      Map.update(
        grid,
        pos,
        panel,
        fn _value ->
          panel
        end
      )

    {pos, facing} = transform(pos, facing, direction)
    {pos, facing, grid}
  end

  def robot(pc_state, pos, facing, grid) do
    {program, pc, rp} = pc_state
    # Get the colour of the current square.
    grid = Map.put_new(grid, pos, %Panel{})
    panel = grid[pos]
    color = from_color(panel.color)

    case Aoc11.run(program, [color], [], pc, rp) do
      {:halt, _, _, output, _, _} ->
        {_, _, grid} = do_the_robot(output, pos, facing, grid)
        grid

      {:blocked, program, _, output, pc, rp} ->
        {pos, facing, grid} = do_the_robot(output, pos, facing, grid)
        robot({program, pc, rp}, pos, facing, grid)
    end
  end

  def vanity() do
    grid = %{
      {0, 0} => %Aoc11.Panel{
        color: :white
      }
    }
    painted = robot(
      {
        load(),
        0,
        0
      },
      {0, 0},
      :up,
      grid
    )

    image = :egd.create(41, 8)
    black = :egd.color({:black, 0})
    white = :egd.color({255, 255, 255})

    Enum.each(
      -1..6,
      fn y ->
        Enum.each(
          0..40,
          fn x ->
            panel = painted[{x, -y}]
            panel = if panel == nil do
              %Panel{}
            else
              panel
            end

            case panel.color do
              :white -> :egd.line(image, {x, y+1}, {x, y+1}, white)
              :black -> :egd.line(image, {x, y+1}, {x, y+1}, black)
            end
          end
        )
      end
    )
    File.write!("output/11.png", :egd.render(image))
    :egd.destroy(image)
  end

  def part1() do
    grid = %{{0, 0} => %Aoc11.Panel{}}
    robot({load(), 0, 0}, {0, 0}, :up, grid)
    |> Enum.count
  end

  def part2() do
    grid = %{
      {0, 0} => %Aoc11.Panel{
        color: :white
      }
    }
    painted = robot(
      {
        load(),
        0,
        0
      },
      {0, 0},
      :up,
      grid
    )
    Enum.each(
      -1..6,
      fn y ->
        Enum.each(
          0..40,
          fn x ->
            panel = painted[{x, -y}]
            panel = if panel == nil do
              %Panel{}
            else
              panel
            end

            case panel.color do
              :white -> IO.write(" ")
              :black -> IO.write("█")
            end
          end
        )
        IO.write("\n")
      end
    )
  end
end
