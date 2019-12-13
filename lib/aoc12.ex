defmodule Aoc12 do
  require Logger

  defmodule Moon do
    defstruct x: 0, y: 0, z: 0, vx: 0, vy: 0, vz: 0, energy: 0
  end

  defimpl String.Chars, for: Moon do
    def to_string(moon) do
      "pos=<x=#{moon.x}, y=#{moon.y}, z=#{moon.z}>, vel=<x=#{moon.vx}, y=#{moon.vy}, z=#{moon.vz}>, energy=#{
        moon.energy
      }"
    end
  end

  def calculate_gravity(moon, other) do
    moon =
      cond do
        moon.x < other.x -> %{moon | vx: moon.vx + 1}
        moon.x > other.x -> %{moon | vx: moon.vx - 1}
        moon.x == other.x -> moon
      end

    moon =
      cond do
        moon.y < other.y -> %{moon | vy: moon.vy + 1}
        moon.y > other.y -> %{moon | vy: moon.vy - 1}
        moon.y == other.y -> moon
      end

    moon =
      cond do
        moon.z < other.z -> %{moon | vz: moon.vz + 1}
        moon.z > other.z -> %{moon | vz: moon.vz - 1}
        moon.z == other.z -> moon
      end

    moon
  end

  def apply_gravity(moon) do
    %{moon | x: moon.x + moon.vx, y: moon.y + moon.vy, z: moon.z + moon.vz}
  end

  def get_energy(moon) do
    (abs(moon.x) + abs(moon.y) + abs(moon.z)) * (abs(moon.vx) + abs(moon.vy) + abs(moon.vz))
  end

  def stationary(moon) do
    moon.vx == 0 && moon.vy == 0 && moon.vz == 0
  end

  def load() do
    File.read!("input/12")
    |> String.split("\n")
    |> Enum.map(fn element ->
      {x, y, z} =
        Regex.scan(~r/\-?\d+/, element)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      %Moon{x: x, y: y, z: z}
    end)
  end

  def load(string) do
    String.trim(string)
    |> String.split("\n")
    |> Enum.map(fn element ->
      {x, y, z} =
        Regex.scan(~r/\-?\d+/, element)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      %Moon{x: x, y: y, z: z}
    end)
  end

  def step(moons) do
    Enum.reduce(
      moons,
      [],
      fn moon, acc ->
        [
          Enum.reduce(
            moons,
            moon,
            fn moon2, moon ->
              calculate_gravity(moon, moon2)
            end
          )
          | acc
        ]
      end
    )
    |> Enum.reverse()
    |> Enum.map(&apply_gravity/1)
  end

  def simulate(moons, 0) do
    moons
    |> Enum.map(&get_energy/1)
    |> Enum.sum()
  end

  def simulate(moons, steps) do
    simulate(step(moons), steps - 1)
  end

  def find_repeating(moons, extract, visited \\ MapSet.new(), count \\ 0)

  def find_repeating(moons, extract, visited, count) do
    moons = step(moons)

    stage =
      Enum.map(moons, extract)
      |> List.to_tuple()

    if MapSet.member?(visited, stage) do
      count
    else
      find_repeating(moons, extract, MapSet.put(visited, stage), count + 1)
    end
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))
  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  def part1() do
    moons = load()
    simulate(moons, 1000)
  end

  def part2() do
    moons = load()
    x = find_repeating(moons, fn m -> {m.x, m.vx} end)
    y = find_repeating(moons, fn m -> {m.y, m.vy} end)
    z = find_repeating(moons, fn m -> {m.z, m.vz} end)
    lcm(lcm(x, y), z)
  end
end
