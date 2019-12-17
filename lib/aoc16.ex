defmodule Aoc16 do
  def load() do
    File.read!("input/16")
  end

  def load(source) do
    source
  end

  def digits(string) do
    num = String.to_integer(string)

    if String.starts_with?(string, "0") do
      [0] ++ Integer.digits(num)
    else
      Integer.digits(num)
    end
  end

  def base(layer) do
    [
      List.duplicate(0, layer),
      List.duplicate(1, layer),
      List.duplicate(0, layer),
      List.duplicate(-1, layer)
    ]
    |> List.flatten()
    |> Stream.cycle()
    |> Stream.drop(1)
  end

  def fft(num, count) do
    Enum.reduce(
      1..count,
      num,
      fn _, num ->
        fft_step(num)
      end
    )
    |> Enum.take(8)
    |> Enum.join("")
  end

  def fft_step(digits) when is_list(digits) do
    Enum.map(
      1..Enum.count(digits),
      fn i ->
        encoding = base(i)

        layer =
          Enum.zip(digits, encoding)
          |> Enum.map(fn {x, y} -> x * y end)

        Integer.mod(Kernel.abs(Enum.sum(layer)), 10)
      end
    )
  end

  def fft_step(num) do
    digits = digits(num)
    fft_step(digits)
  end

  def part1() do
    load()
    |> digits()
    |> fft(100)
  end

  def part2() do
    nums =
      load()
      |> digits()
      |> List.duplicate(10000)
      |> List.flatten()

    offset =
      nums
      |> Enum.take(7)
      |> Integer.undigits()

    nums =
      Enum.drop(nums, offset)
      |> Enum.reverse()

    Enum.reduce(
      1..100,
      nums,
      fn _, acc ->
        Enum.scan(acc, fn x, y -> Integer.mod(x + y, 10) end)
      end
    )
    |> Enum.reverse()
    |> Enum.take(8)
    |> Integer.undigits()
  end
end
