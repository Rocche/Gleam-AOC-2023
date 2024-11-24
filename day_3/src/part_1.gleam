import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type EngineElement {
  EngineElement(element: String, row: Int, col: Int)
}

fn is_numeric(char: String) -> Bool {
  case char |> int.base_parse(10) {
    Error(Nil) -> False
    _ -> True
  }
}

fn is_number_adjacent_to_symbol(
  num_row: Int,
  num_col1: Int,
  num_col2: Int,
  sym_row: Int,
  sym_col: Int,
) -> Bool {
  let adjacent_vertical = sym_row >= num_row - 1 && sym_row <= num_row + 1
  let adjacent_horizontal = sym_col >= num_col1 - 1 && sym_col <= num_col2 + 1
  adjacent_vertical && adjacent_horizontal
}

fn is_number_adjacent_to_any_symbol(
  number: EngineElement,
  symbols: List(EngineElement),
) -> Bool {
  list.any(symbols, fn(sym) {
    is_number_adjacent_to_symbol(
      number.row,
      number.col,
      number.col + string.length(number.element) - 1,
      sym.row,
      sym.col,
    )
  })
}

fn parse_line_loop(
  line: String,
  current_element: String,
  current_element_start: Int,
  current_index: Int,
  row: Int,
  engine_elements: List(EngineElement),
) -> List(EngineElement) {
  case string.pop_grapheme(line), current_element {
    Error(Nil), "" -> engine_elements
    Error(Nil), num -> [
      EngineElement(num, row, current_element_start),
      ..engine_elements
    ]
    Ok(#(".", rest)), "" ->
      parse_line_loop(
        rest,
        "",
        current_index + 1,
        current_index + 1,
        row,
        engine_elements,
      )
    Ok(#(".", rest)), _ ->
      parse_line_loop(rest, "", current_index + 1, current_index + 1, row, [
        EngineElement(current_element, row, current_element_start),
        ..engine_elements
      ])
    Ok(#(s, rest)), element -> {
      case is_numeric(s), element {
        True, _ ->
          parse_line_loop(
            rest,
            element <> s,
            current_element_start,
            current_index + 1,
            row,
            engine_elements,
          )
        False, "" ->
          parse_line_loop(rest, "", current_index + 1, current_index + 1, row, [
            EngineElement(s, row, current_index),
            ..engine_elements
          ])
        False, _ ->
          parse_line_loop(rest, "", current_index + 1, current_index + 1, row, [
            EngineElement(current_element, row, current_element_start),
            EngineElement(s, row, current_index),
            ..engine_elements
          ])
      }
    }
  }
}

fn parse_lines_loop(
  lines: List(String),
  line_number: Int,
  elements: List(EngineElement),
) -> List(EngineElement) {
  case lines {
    [] -> elements
    [line, ..rest] ->
      parse_lines_loop(
        rest,
        line_number + 1,
        list.append(elements, parse_line_loop(line, "", 0, 0, line_number, [])),
      )
  }
}

fn parse_lines(lines: List(String)) -> List(EngineElement) {
  parse_lines_loop(lines, 0, [])
}

pub fn get_lines(filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(s) { !string.is_empty(s) })
}

pub fn run() {
  let filepath = "real_input.txt"
  let engine_elements =
    get_lines(filepath)
    |> parse_lines
  let numbers =
    engine_elements |> list.filter(fn(el) { is_numeric(el.element) })
  let symbols =
    engine_elements |> list.filter(fn(el) { !is_numeric(el.element) })
  let result =
    numbers
    |> list.filter(is_number_adjacent_to_any_symbol(_, symbols))
    |> list.map(fn(num) { int.base_parse(num.element, 10) })
    |> result.values
    |> int.sum
  io.println("Part 1 result is: " <> int.to_string(result))
}
