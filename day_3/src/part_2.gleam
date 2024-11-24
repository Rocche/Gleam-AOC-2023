import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import part_1

fn get_adjacent_numbers(
  symbol: part_1.EngineElement,
  numbers: List(part_1.EngineElement),
) -> List(Int) {
  numbers
  |> list.filter(fn(n) {
    part_1.is_number_adjacent_to_symbol(
      n.row,
      n.col,
      n.col + string.length(n.element) - 1,
      symbol.row,
      symbol.col,
    )
  })
  |> list.map(fn(n) { int.base_parse(n.element, 10) })
  |> result.all
  |> result.unwrap([])
}

pub fn run() {
  let filepath = "real_input.txt"
  let engine_elements =
    part_1.get_lines(filepath)
    |> part_1.parse_lines
  let numbers =
    engine_elements |> list.filter(fn(el) { part_1.is_numeric(el.element) })
  let symbols =
    engine_elements |> list.filter(fn(el) { !part_1.is_numeric(el.element) })
  let result =
    symbols
    |> list.filter(fn(sym) { sym.element == "*" })
    |> list.map(get_adjacent_numbers(_, numbers))
    |> list.filter(fn(nums) { list.length(nums) == 2 })
    |> list.map(fn(nums) { list.reduce(nums, int.multiply) })
    |> result.values
    |> int.sum
  io.println("Part 2 result is: " <> int.to_string(result))
}
