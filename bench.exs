Benchee.run(
  %{
    "AOC1_1" => (fn -> Aoc1.part1() end),
    "AOC1_2" => (fn -> Aoc1.part2() end),
    "AOC2_1" => (fn -> Aoc2.part1() end),
    "AOC2_2" => (fn -> Aoc2.part2() end),
    "AOC3_1" => (fn -> Aoc3.part1() end),
    "AOC3_2" => (fn -> Aoc3.part2() end),
    "AOC4_1" => (fn -> Aoc4.part1() end),
    "AOC4_2" => (fn -> Aoc4.part2() end),
    "AOC5_1" => (fn -> Aoc5.part1() end),
    "AOC5_2" => (fn -> Aoc5.part2() end),
    "AOC6_1" => (fn -> Aoc6.part1() end),
    "AOC6_2" => (fn -> Aoc6.part2() end),
    "AOC7_1" => (fn -> Aoc7.part1() end),
    "AOC7_2" => (fn -> Aoc7.part2() end),
    "AOC8_1" => (fn -> Aoc8.part1() end),
    "AOC8_2" => (fn -> Aoc8.part2() end),
    "AOC9_1" => (fn -> Aoc9.part1() end),
    "AOC9_2" => (fn -> Aoc9.part2() end),
  },
  memory_time: 5,
  parallel: 8
)
