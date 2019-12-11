defmodule Aoc6 do
  def load() do
    File.read!("input/6")
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, ")") end)
  end

  def load(source) do
    source
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x, ")") end)
  end

  def count_orbits(position, _orbits, acc) when position == "COM" do
    acc
  end

  def count_orbits(position, orbits, acc) do
    [target] = orbits[position]
    count_orbits(target, orbits, acc + 1)
  end

  def find_orbits(position, _orbits, path) when position == "COM" do
    path
  end

  def find_orbits(position, orbits, path) do
    [target] = orbits[position]
    find_orbits(target, orbits, [target | path])
  end

  def build_orbits(links) do
    {
      MapSet.new(List.flatten(links)),
      Enum.reduce(
        links,
        %{},
        fn [dest, src], acc ->
          Map.put_new(acc, src, [])
          {_, map} = Map.get_and_update(
            acc,
            src,
            fn current ->
              if current == nil do
                {current, [dest]}
              else
                {current, [dest | current]}
              end
            end
          )
          map
        end
      )
    }
  end

  def route(links) do
    {_, orbits} = Aoc6.build_orbits(links)
    san = Aoc6.find_orbits("YOU", orbits, [])
    you = Aoc6.find_orbits("SAN", orbits, [])
    bridge = Enum.zip(san, you) |> Enum.reverse |> Enum.drop_while(fn {l, r} -> l != r end) |> Enum.at(0) |> elem(0)
    san_jumps = Enum.drop_while(san, fn x -> x != bridge end) |> Enum.drop(1) |> Enum.count
    you_jumps = Enum.drop_while(you, fn x -> x != bridge end) |> Enum.drop(1) |> Enum.count
    san_jumps + you_jumps
  end

  def distance_from_com(links) do
    {nodes, orbits} = build_orbits(links)
    Enum.map(nodes, fn x -> Aoc6.count_orbits(x, orbits, 0) end) |> Enum.sum
  end

  def part1() do
    links = load()
    distance_from_com(links)
  end

  def part2() do
    links = Aoc6.load()
    route(links)
  end
end