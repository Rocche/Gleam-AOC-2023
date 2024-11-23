import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn not_empty(s: String) -> Bool {
  !string.is_empty(s)
}

pub fn get_first_and_last(l: List(Int)) -> List(Int) {
  [list.first(l), list.last(l)]
  |> result.values
}

fn extract_number_from_line(line: String) -> Int {
  line
  |> string.to_graphemes
  |> list.map(int.base_parse(_, 10))
  |> result.values
  |> get_first_and_last
  |> list.map(int.to_string)
  |> string.join("")
  |> int.base_parse(10)
  |> result.unwrap(0)
}

pub fn get_lines(filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(not_empty)
}

pub fn run() {
  let filepath = "real_input.txt"
  let sum =
    get_lines(filepath)
    |> list.map(extract_number_from_line)
    |> int.sum
  io.println("Part one result is: " <> int.to_string(sum))
}
