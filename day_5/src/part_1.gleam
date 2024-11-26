import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Mapping {
  Mapping(dest_start: Int, source_start: Int, range_len: Int)
}

fn get_content_between(
  lines: List(String),
  from: String,
  to: String,
) -> List(String) {
  lines
  |> list.drop_while(fn(l) { l != from })
  |> list.drop(1)
  |> list.take_while(fn(l) { l != to })
}

fn map_number(number: Int, mapping: Mapping) -> Result(Int, Nil) {
  case
    number >= mapping.source_start
    && number <= mapping.source_start + mapping.range_len
  {
    True -> Ok(mapping.dest_start + { number - mapping.source_start })
    False -> Error(Nil)
  }
}

fn map_number_in_category(number: Int, mappings: List(Mapping)) -> Int {
  mappings
  |> list.map(map_number(number, _))
  |> list.reduce(result.or)
  |> result.flatten
  |> result.unwrap(number)
}

fn numbers_line_to_mapping(line: String) -> Mapping {
  let assert [dest, source, range, ..] =
    line
    |> string.split(" ")
    |> list.map(string.trim)
    |> list.map(int.base_parse(_, 10))
    |> result.values
  Mapping(dest, source, range)
}

fn lines_to_mapping(lines: List(String)) -> List(Mapping) {
  lines
  |> list.map(numbers_line_to_mapping)
}

pub fn get_seeds(lines: List(String)) -> List(Int) {
  let assert Ok(seed_line) = list.first(lines)
  seed_line
  |> string.split(":")
  |> list.last
  |> result.try(fn(nums) {
    nums
    |> string.split(" ")
    |> list.map(string.trim)
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.map(int.base_parse(_, 10))
    |> result.all
  })
  |> result.unwrap([])
}

pub fn get_chain_of_mappings(lines: List(String)) -> List(List(Mapping)) {
  let categories = [
    "seed-to-soil", "soil-to-fertilizer", "fertilizer-to-water",
    "water-to-light", "light-to-temperature", "temperature-to-humidity",
    "humidity-to-location", "",
  ]
  categories
  |> list.window_by_2
  |> list.map(fn(from_to) {
    get_content_between(lines, from_to.0 <> " map:", from_to.1 <> " map:")
  })
  |> list.map(lines_to_mapping)
}

pub fn get_location_for_seed(seed: Int, mappings: List(List(Mapping))) -> Int {
  mappings
  |> list.fold(from: seed, with: map_number_in_category)
}

pub fn get_lines(filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(s) { !string.is_empty(s) })
}

pub fn run() {
  let lines = get_lines("real_input.txt")
  let seeds =
    lines
    |> get_seeds
  let mappings =
    lines
    |> get_chain_of_mappings
  let result =
    seeds
    |> list.map(get_location_for_seed(_, mappings))
    |> list.reduce(int.min)
    |> result.unwrap(-1)
  io.println("Part 1 result is: " <> int.to_string(result))
}
