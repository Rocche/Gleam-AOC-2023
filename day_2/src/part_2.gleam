import gleam/int
import gleam/io
import gleam/list
import part_1

fn get_cubes_power(sets: List(#(Int, Int, Int))) -> Int {
  let assert Ok(red) =
    sets
    |> list.map(fn(s) { s.0 })
    |> list.reduce(int.max)
  let assert Ok(green) =
    sets
    |> list.map(fn(s) { s.1 })
    |> list.reduce(int.max)
  let assert Ok(blue) =
    sets
    |> list.map(fn(s) { s.2 })
    |> list.reduce(int.max)
  red * green * blue
}

pub fn run() {
  let filepath = "real_input.txt"
  let result =
    part_1.get_lines(filepath)
    |> list.map(part_1.parse_line)
    |> list.map(fn(g) { get_cubes_power(g.1) })
    |> int.sum
  io.println("Second part result: " <> int.to_string(result))
}
