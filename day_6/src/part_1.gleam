import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn get_numbers_from_line(line: String) -> List(Int) {
  line
  |> string.split(" ")
  |> list.drop(1)
  |> list.map(string.trim)
  |> list.map(int.base_parse(_, 10))
  |> result.values
}

pub fn get_times_distances(lines: List(String)) -> List(#(Int, Int)) {
  let assert Ok(times_line) = lines |> list.first
  let times = times_line |> get_numbers_from_line
  let assert Ok(distances_line) = lines |> list.last
  let distances = distances_line |> get_numbers_from_line
  times |> list.zip(distances)
}

fn calculate_distance(total_time: Int, hold_time: Int) -> Int {
  hold_time * { total_time - hold_time }
}

pub fn get_race_winning_combinations(race: #(Int, Int)) -> Int {
  // should be better to use iterators instead of list, especially
  // for part 2 of the challenge
  list.range(0, race.0)
  |> list.map(calculate_distance(race.0, _))
  |> list.filter(fn(d) { d > race.1 })
  |> list.length
}

pub fn get_lines(filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(s) { !string.is_empty(s) })
}

pub fn run() {
  let result =
    get_lines("real_input.txt")
    |> get_times_distances
    |> list.map(get_race_winning_combinations)
    |> list.fold(1, int.multiply)
  io.println("Result of part 1 is: " <> int.to_string(result))
}
