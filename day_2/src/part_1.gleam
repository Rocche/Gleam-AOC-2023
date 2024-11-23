import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn is_possible_set(set_of_cubes: #(Int, Int, Int)) -> Bool {
  case set_of_cubes {
    #(red, _, _) if red > 12 -> False
    #(_, green, _) if green > 13 -> False
    #(_, _, blue) if blue > 14 -> False
    _ -> True
  }
}

fn is_possible_game(game: #(Int, List(#(Int, Int, Int)))) -> Bool {
  game.1 |> list.all(is_possible_set)
}

fn get_id(line: String) -> Int {
  let assert Ok(id_part) =
    line
    |> string.split(":")
    |> list.first
  id_part
  |> string.replace("Game ", "")
  |> int.base_parse(10)
  |> result.unwrap(0)
}

fn get_color(set_components: List(String), color: String) -> Int {
  let color_component =
    set_components
    |> list.filter(string.contains(_, color))
    |> list.first
  case color_component {
    Error(Nil) -> 0
    Ok(content) ->
      content
      |> string.trim
      |> string.replace(" " <> color, "")
      |> int.base_parse(10)
      |> result.unwrap(0)
  }
}

fn parse_set(set: String) -> #(Int, Int, Int) {
  let set_components = set |> string.split(",")
  #(
    get_color(set_components, "red"),
    get_color(set_components, "green"),
    get_color(set_components, "blue"),
  )
}

fn parse_sets(line: String) -> List(#(Int, Int, Int)) {
  let assert Ok(sets_part) =
    line
    |> string.trim
    |> string.split(":")
    |> list.last
  sets_part |> string.split(";") |> list.map(parse_set)
}

pub fn parse_line(line: String) -> #(Int, List(#(Int, Int, Int))) {
  #(get_id(line), parse_sets(line))
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
  let result =
    get_lines(filepath)
    |> list.map(parse_line)
    |> list.filter(is_possible_game)
    |> list.map(fn(g) { g.0 })
    |> int.sum
  io.println("First part result: " <> int.to_string(result))
}
