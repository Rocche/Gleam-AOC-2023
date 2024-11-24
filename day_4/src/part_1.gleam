import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn parse_numbers(numbers: String) -> List(Int) {
  numbers
  |> string.split(" ")
  |> list.map(string.trim)
  |> list.map(int.base_parse(_, 10))
  |> result.values
}

pub fn parse_line(line: String) -> #(List(Int), List(Int)) {
  let numbers_part =
    line
    |> string.trim
    |> string.split(": ")
    |> list.last
    |> result.unwrap("")
    |> string.split(" | ")
  let winning_nums =
    numbers_part
    |> list.first
    |> result.unwrap("")
    |> parse_numbers
  let got_nums =
    numbers_part
    |> list.last
    |> result.unwrap("")
    |> parse_numbers
  #(winning_nums, got_nums)
}

pub fn count_winning_numbers(
  winning_nums: List(Int),
  got_nums: List(Int),
) -> Int {
  winning_nums
  |> list.filter(fn(n) { list.contains(got_nums, n) })
  |> list.length
}

fn count_winning_points(winning_nums: List(Int), got_nums: List(Int)) -> Int {
  case count_winning_numbers(winning_nums, got_nums) {
    0 -> 0
    n ->
      n - 1
      |> int.to_float
      |> int.power(2, _)
      |> result.unwrap(0.0)
      |> float.truncate
  }
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
    |> list.map(parse_line)
    |> list.map(fn(pair) { count_winning_points(pair.0, pair.1) })
    |> int.sum
  io.println("Part 1 result is: " <> int.to_string(result))
}
