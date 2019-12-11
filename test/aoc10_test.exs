defmodule Aoc10Test do
  use ExUnit.Case, async: true
  @map1 ("""
         .#..#
         .....
         #####
         ....#
         ...##
         """)
  @map2 ("""
         ......#.#.
         #..#.#....
         ..#######.
         .#.#.###..
         .#..#.....
         ..#....#.#
         #..#....#.
         .##.#..###
         ##...#..#.
         .#....####
         """)
  @map3 ("""
         #.#...#.#.
         .###....#.
         .#....#...
         ##.#.#.#.#
         ....#.#.#.
         .##..###.#
         ..#...##..
         ..##....##
         ......#...
         .####.###.
         """)
  @map4 ("""
         .#..#..###
         ####.###.#
         ....###.#.
         ..###.##.#
         ##.##.#.#.
         ....###..#
         ..#.#..#.#
         #..#.#.###
         .##...##.#
         .....#.#..
         """)

  @map5 ("""
         .#..##.###...#######
         ##.############..##.
         .#.######.########.#
         .###.#######.####.#.
         #####.##.#.##.###.##
         ..#####..#.#########
         ####################
         #.####....###.#.#.##
         ##.#################
         #####.##.###..####..
         ..######..##.#######
         ####.##.####...##..#
         .#####..#.######.###
         ##...#.##########...
         #.##########.#######
         .####.#.###.###.#.##
         ....##.##.###..#####
         .#.#.###########.###
         #.#.#.#####.####.###
         ###.##.####.##.#..##
         """)

  @map6 ("""
         .#....#####...#..
         ##...##.#####..##
         ##...#...#.#####.
         ..#.....X...###..
         ..#.#.....#....##
         """)

  test "part 1 example 1" do
    map = Aoc10.load(@map1)
    grid = Aoc10.build_grid(map)
    assert Aoc10.solve_for_los(grid) == {{3, 4}, 8}
  end

  test "part 1 example 2" do
    map = Aoc10.load(@map2)
    grid = Aoc10.build_grid(map)
    assert Aoc10.solve_for_los(grid) == {{5, 8}, 33}
  end

  test "part 1 example 3" do
    map = Aoc10.load(@map3)
    grid = Aoc10.build_grid(map)
    assert Aoc10.solve_for_los(grid) == {{1, 2}, 35}
  end

  test "part 1 example 4" do
    map = Aoc10.load(@map4)
    grid = Aoc10.build_grid(map)
    assert Aoc10.solve_for_los(grid) == {{6, 3}, 41}
  end

  test "part 1 example 5" do
    map = Aoc10.load(@map5)
    grid = Aoc10.build_grid(map)
    assert Aoc10.solve_for_los(grid) == {{11, 13}, 210}
  end

  test "part 1" do
    assert Aoc10.part1() == {{29, 28}, 256}
  end

  test "part 2" do
    # Could never get this one to work. Day 10 sucked :(
  end
end
