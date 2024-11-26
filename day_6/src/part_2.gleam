import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import part_1

fn get_number_from_line(line: String) -> Int {
  line
  |> string.split(" ")
  |> list.drop(1)
  |> list.map(string.trim)
  |> string.join("")
  |> int.base_parse(10)
  |> result.unwrap(0)
}

fn get_times_distances(lines: List(String)) -> #(Int, Int) {
  let assert Ok(times_line) = lines |> list.first
  let time = times_line |> get_number_from_line
  let assert Ok(distances_line) = lines |> list.last
  let distance = distances_line |> get_number_from_line
  #(time, distance)
}

pub fn run() {
  let result =
    part_1.get_lines("real_input.txt")
    |> get_times_distances
    |> part_1.get_race_winning_combinations
  io.println("Result of part 1 is: " <> int.to_string(result))
}
