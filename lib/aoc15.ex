defmodule UI do
  alias ExTermbox.Bindings, as: Termbox
  alias ExTermbox.{Cell, EventManager, Event, Position}

  defstruct drone_x: 0, drone_y: 0, oxygen_x: 0, oxygen_y: 0, found_oxygen: false

  @up 65517
  @down 65516
  @left 65515
  @right 65514

  def init() do
    :ok = Termbox.init()
    {:ok, _pid} = EventManager.start_link()
    :ok = EventManager.subscribe(self())
  end

  def erase_drone(x, y) do
    Termbox.put_cell(%Cell{
      Cell.empty()
      | ch: ?\s,
        position: %Position{
          x: x,
          y: y
        }
    })
  end

  def draw_drone(x, y) do
    Termbox.put_cell(%Cell{
      position: %Position{
        x: x,
        y: y
      },
      ch: ?D
    })
  end

  def draw_wall(x, y) do
    Termbox.put_cell(%Cell{
      position: %Position{
        x: x,
        y: y
      },
      ch: ?█
    })
  end

  def draw_start(x, y) do
    Termbox.put_cell(%Cell{
      position: %Position{
        x: x,
        y: y
      },
      ch: ??
    })
  end

  def draw_oxygen(x, y) do
    Termbox.put_cell(%Cell{
      position: %Position{
        x: x,
        y: y
      },
      ch: ?!
    })
  end

  def up(ui_state, ic_state) do
    {_, [output], ic_state} = step(ic_state, 1)

    case output do
      0 ->
        draw_wall(ui_state.drone_x, ui_state.drone_y - 1)
        {:continue, ui_state, ic_state}

      1 ->
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x, drone_y: ui_state.drone_y - 1}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      2 ->
        ui_state = %UI{ui_state | oxygen_x: ui_state.drone_x, oxygen_y: ui_state.drone_y - 1, found_oxygen: true}
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x, drone_y: ui_state.drone_y - 1}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}
    end
  end

  def down(ui_state, ic_state) do
    {_, [output], ic_state} = step(ic_state, 2)

    case output do
      0 ->
        draw_wall(ui_state.drone_x, ui_state.drone_y + 1)
        {:continue, ui_state, ic_state}

      1 ->
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x, drone_y: ui_state.drone_y + 1}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      2 ->
        ui_state = %UI{ui_state | oxygen_x: ui_state.drone_x, oxygen_y: ui_state.drone_y + 1, found_oxygen: true}
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x, drone_y: ui_state.drone_y + 1}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}
    end
  end

  def left(ui_state, ic_state) do
    {_, [output], ic_state} = step(ic_state, 3)

    case output do
      0 ->
        draw_wall(ui_state.drone_x - 1, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      1 ->
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x - 1, drone_y: ui_state.drone_y}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      2 ->
        ui_state = %UI{ui_state | oxygen_x: ui_state.drone_x - 1, oxygen_y: ui_state.drone_y, found_oxygen: true}
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x - 1, drone_y: ui_state.drone_y}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}
    end
  end

  def right(ui_state, ic_state) do
    {_, [output], ic_state} = step(ic_state, 4)

    case output do
      0 ->
        draw_wall(ui_state.drone_x + 1, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      1 ->
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x + 1, drone_y: ui_state.drone_y}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}

      2 ->
        ui_state = %UI{ui_state | oxygen_x: ui_state.drone_x + 1, oxygen_y: ui_state.drone_y, found_oxygen: true}
        erase_drone(ui_state.drone_x, ui_state.drone_y)
        ui_state = %UI{ui_state | drone_x: ui_state.drone_x + 1, drone_y: ui_state.drone_y}
        draw_drone(ui_state.drone_x, ui_state.drone_y)
        {:continue, ui_state, ic_state}
    end
  end

  def loop(ui_state, ic_state, timeout \\ :infinity) do
    x = Kernel.round(Termbox.width() / 2)
    y = Kernel.round(Termbox.height() / 2)
    draw_start(x, y)

    if ui_state.found_oxygen do
      draw_oxygen(ui_state.oxygen_x, ui_state.oxygen_y)
    end

    Termbox.present()

    receive do
      {:event, %Event{key: @up}} ->
        {state, ui_state, ic_state} = up(ui_state, ic_state)

        case state do
          :continue -> loop(ui_state, ic_state, timeout)
          :halt -> :halt
        end

      {:event, %Event{key: @down}} ->
        {state, ui_state, ic_state} = down(ui_state, ic_state)

        case state do
          :continue -> loop(ui_state, ic_state, timeout)
          :halt -> :halt
        end

      {:event, %Event{key: @left}} ->
        {state, ui_state, ic_state} = left(ui_state, ic_state)

        case state do
          :continue -> loop(ui_state, ic_state, timeout)
          :halt -> :halt
        end

      {:event, %Event{key: @right}} ->
        {state, ui_state, ic_state} = right(ui_state, ic_state)

        case state do
          :continue -> loop(ui_state, ic_state, timeout)
          :halt -> :halt
        end

      {:event, %Event{ch: ?r}} ->
        loop(ui_state, ic_state, 0)

      {:event, %Event{ch: ?s}} ->
        loop(ui_state, ic_state)

      {:event, %Event{ch: ?q}} ->
        :ok = Termbox.shutdown()
    after
      timeout ->
        function = Enum.random([&up/2, &down/2, &left/2, &right/2])
        {state, ui_state, ic_state} = function.(ui_state, ic_state)

        case state do
          :continue -> loop(ui_state, ic_state, timeout)
          :halt -> :halt
        end
    end
  end

  def step({program, pc, rp}, direction) do
    {state, program, _, output, pc, rp} = Aoc15.run(program, [direction], [], pc, rp)
    {state, output, {program, pc, rp}}
  end

  def run(ui_state, ic_state) do
    x = Kernel.round(Termbox.width() / 2)
    y = Kernel.round(Termbox.height() / 2)
    draw_start(x, y)
    draw_drone(x, y)
    Termbox.present()
    ui_state = %UI{ui_state | drone_x: x, drone_y: y}
    loop(ui_state, ic_state)
  end
end

defmodule SearchBot do
  def type(0), do: :wall
  def type(1), do: :empty
  def type(2), do: :o2

  def direction_to_num(:up), do: 1
  def direction_to_num(:down), do: 2
  def direction_to_num(:left), do: 3
  def direction_to_num(:right), do: 4

  def opposite(:up), do: :down
  def opposite(:down), do: :up
  def opposite(:left), do: :right
  def opposite(:right), do: :left

  def up({x, y}), do: {x, y - 1}
  def down({x, y}), do: {x, y + 1}
  def left({x, y}), do: {x - 1, y}
  def right({x, y}), do: {x + 1, y}

  def look_around(program, pc, rp) do
    {:blocked, _, _, [up], _, _} = Aoc15.run(program, [1], [], pc, rp)
    {:blocked, _, _, [down], _, _} = Aoc15.run(program, [2], [], pc, rp)
    {:blocked, _, _, [left], _, _} = Aoc15.run(program, [3], [], pc, rp)
    {:blocked, _, _, [right], _, _} = Aoc15.run(program, [4], [], pc, rp)

    [
      up: type(up),
      down: type(down),
      left: type(left),
      right: type(right)
    ]
  end

  def search(supervisor, program, pc, rp, came_from, {x, y}, path) do
    directions = look_around(program, pc, rp)
    choices = Enum.filter(directions, fn {direction, type} -> type != :wall && direction != came_from end)

    case choices do
      [] ->
        send(supervisor, :suicide)

      [{_, :o2}] ->
        send(supervisor, {:success, [{x, y} | path], came_from, program, pc, rp})

      [{direction, _}] ->
        # Continue walking our lonely road.
        {:blocked, program, _, _, pc, rp} = Aoc15.run(program, [direction_to_num(direction)], [], pc, rp)
        came_from = opposite(direction)

        cords =
          case direction do
            :up -> up({x, y})
            :down -> down({x, y})
            :left -> left({x, y})
            :right -> right({x, y})
          end

        search(supervisor, program, pc, rp, came_from, cords, [{x, y} | path])

      directions ->
        Enum.each(
          directions,
          fn {direction, _} ->
            {:blocked, program, _, _, pc, rp} = Aoc15.run(program, [direction_to_num(direction)], [], pc, rp)
            came_from = opposite(direction)

            cords =
              case direction do
                :up -> up({x, y})
                :down -> down({x, y})
                :left -> left({x, y})
                :right -> right({x, y})
              end

            spawn(fn ->
              search(supervisor, program, pc, rp, came_from, cords, [{x, y} | path])
            end)
          end
        )

        send(supervisor, :suicide)
    end
  end

  def fill(supervisor, program, pc, rp, came_from, {x, y}, minutes_run) do
    directions = look_around(program, pc, rp)
    choices = Enum.filter(directions, fn {direction, type} -> type != :wall && direction != came_from end)

    case choices do
      [] ->
        send(supervisor, {:suicide, minutes_run})

      [{_, :o2}] ->
        send(supervisor, {:suicide, minutes_run})

      [{direction, _}] ->
        # Continue walking our lonely road.
        {:blocked, program, _, _, pc, rp} = Aoc15.run(program, [direction_to_num(direction)], [], pc, rp)
        came_from = opposite(direction)

        cords =
          case direction do
            :up -> up({x, y})
            :down -> down({x, y})
            :left -> left({x, y})
            :right -> right({x, y})
          end

        fill(supervisor, program, pc, rp, came_from, cords, minutes_run + 1)

      directions ->
        Enum.each(
          directions,
          fn {direction, _} ->
            {:blocked, program, _, _, pc, rp} = Aoc15.run(program, [direction_to_num(direction)], [], pc, rp)
            came_from = opposite(direction)

            cords =
              case direction do
                :up -> up({x, y})
                :down -> down({x, y})
                :left -> left({x, y})
                :right -> right({x, y})
              end

            spawn(fn ->
              send(supervisor, :cloned)
              fill(supervisor, program, pc, rp, came_from, cords, minutes_run + 1)
            end)
          end
        )

        send(supervisor, {:suicide, minutes_run})
    end
  end

  def search_result_loop(death_count) do
    receive do
      :suicide ->
        search_result_loop(death_count + 1)

      {:success, path, final_direction, program, pc, rp} ->
        {path, death_count, final_direction, program, pc, rp}
    end
  end

  def fill_results_loop(live_clones, longest_run, death_count) when live_clones == 0 do
    {longest_run + 1, death_count}
  end

  def fill_results_loop(live_clones, longest_run, death_count) do
    receive do
      :cloned ->
        fill_results_loop(live_clones + 1, longest_run, death_count)

      {:suicide, total_time} ->
        if total_time > longest_run do
          fill_results_loop(live_clones - 1, total_time, death_count + 1)
        else
          fill_results_loop(live_clones - 1, longest_run, death_count + 1)
        end
    end
  end

  def run_search(program, width, height) do
    me = self()
    spawn(fn -> search(me, program, 0, 0, :down, {width, height}, []) end)
    search_result_loop(0)
  end

  def run_fill(program, width, height) do
    me = self()

    spawn(fn -> search(me, program, 0, 0, :down, {width, height}, []) end)
    {path, _, final_direction, program, pc, rp} = search_result_loop(0)
    [{ox_x, ox_y} | _] = path
    spawn(fn -> fill(me, program, pc, rp, opposite(final_direction), {ox_x, ox_y}, 0) end)
    fill_results_loop(1, 0, 0)
  end
end

defmodule Aoc15 do
  def load() do
    File.read!("input/15")
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
              _ -> throw("Bad addressing mode #{value}")
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

  def run({_state, program, input, output, pc, rp}), do: run(program, input, output, pc, rp)

  def run(program, input, output, pc \\ 0, rp \\ 0) do
    instruction = Enum.at(program, pc)
    opcode = decode(instruction)

    case step(opcode, program, input, output, pc, rp) do
      {:halt, program, input, output, pc, rp} -> {:halt, program, input, output, pc, rp}
      {:blocked, program, input, output, pc, rp} -> {:blocked, program, input, output, pc, rp}
      {:continue, program, input, output, pc, rp} -> run(program, input, output, pc, rp)
    end
  end

  def ui() do
    {:blocked, program, _, _, pc, rp} =
      load()
      |> run([], [])

    UI.init()
    UI.run(%UI{}, {program, pc, rp})
  end

  def part1() do
    width = 80
    height = 22

    {path, death_count, _, _, _, _} =
      load()
      |> SearchBot.run_search(width, height)

    IO.puts("Final death count: #{death_count}")
    Enum.count(path)
  end

  def part2() do
    width = 80
    height = 22

    {result, death_count} =
      load()
      |> SearchBot.run_fill(width, height)

    IO.puts("Final death count: #{death_count}")
    result
  end
end
