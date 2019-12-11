defmodule Aoc8 do
  def load() do
    digits =
      File.read!("input/8")
      |> String.to_integer()
      |> Integer.digits()

    # My input started with a 0. Fuck my life.
    [0 | digits]
  end

  def load(input) do
    digits =
      String.to_integer(input)
      |> Integer.digits()

    if String.starts_with?(input, "0") do
      [0 | digits]
    else
      digits
    end
  end

  def build(digits, height, width) do
    Enum.chunk_every(digits, height * width)
  end

  def part1() do
    layers = build(load(), 25, 6)
    min = Enum.min_by(layers, fn x -> Enum.count(x, &(&1 == 0)) end)
    ones = Enum.count(min, &(&1 == 1))
    twos = Enum.count(min, &(&1 == 2))
    ones * twos
  end

  def draw(name, layers, width, height) do
    image = :egd.create(width, height)
    black = :egd.color({:black, 0})
    white = :egd.color({255, 255, 255})
    layers = Enum.reverse(layers)
    Enum.map(layers, fn layer -> Enum.chunk_every(layer, width) end)

    Enum.each(
      layers,
      fn layer ->
        rows = Enum.chunk_every(layer, width)

        Enum.each(
          Enum.with_index(rows),
          fn {pixels, row} ->
            Enum.each(
              Enum.with_index(pixels),
              fn {pixel, col} ->
                case pixel do
                  0 -> :egd.line(image, {col, row}, {col, row}, white)
                  1 -> :egd.line(image, {col, row}, {col, row}, black)
                  2 -> :noop
                end
              end
            )
          end
        )
      end
    )

    File.write!(name, :egd.render(image))
    :egd.destroy(image)
  end

  def part2() do
    layers = build(load(), 25, 6)
    draw("output/8.png", layers, 25, 6)
  end
end
