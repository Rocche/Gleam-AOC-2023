import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import gleam/yielder
import simplifile

pub type Instruction {
  Right
  Left
}

fn char_to_instruction(char: String) -> Instruction {
  case char {
    "R" -> Right
    _ -> Left
  }
}

pub type Node {
  Node(name: String, left: String, right: String)
}

fn execute_instruction(
  nodes: Dict(String, Node),
  current_node: String,
  instruction: Instruction,
) -> String {
  let node = nodes |> dict.get(current_node)
  case node, instruction {
    Error(Nil), _ -> current_node
    Ok(n), Right -> n.right
    Ok(n), Left -> n.left
  }
}

fn execute_instructions(
  nodes: Dict(String, Node),
  current_node: String,
  instructions: List(Instruction),
) -> String {
  instructions
  |> list.fold(current_node, fn(n, i) { execute_instruction(nodes, n, i) })
}

fn get_instructions(lines: List(String)) -> List(Instruction) {
  let assert Ok(instructions_line) = lines |> list.first
  instructions_line
  |> string.to_graphemes
  |> list.map(char_to_instruction)
}

fn parse_node_line(line: String) -> #(String, Node) {
  let assert Ok(re) =
    regexp.from_string("^(\\w{3}) = \\((\\w{3}), (\\w{3})\\)$")
  let submatches =
    line
    |> regexp.scan(re, _)
    |> list.first
    |> result.try(fn(match) { Ok(match.submatches) })
  case submatches {
    Ok([Some(node), Some(left), Some(right)]) -> #(
      node,
      Node(node, left, right),
    )
    _ -> panic
  }
}

fn find_number_of_instructions_loop(
  nodes: Dict(String, Node),
  current_node: String,
  current_instructions: List(Instruction),
  all_instructions: List(Instruction),
  count: Int,
) -> Int {
  case current_node, current_instructions {
    "ZZZ", [] -> count
    _, [] ->
      find_number_of_instructions_loop(
        nodes,
        current_node,
        all_instructions,
        all_instructions,
        count,
      )
    _, [x, ..xs] ->
      find_number_of_instructions_loop(
        nodes,
        execute_instruction(nodes, current_node, x),
        xs,
        all_instructions,
        count + 1,
      )
  }
}

fn find_number_of_instructions(
  nodes: Dict(String, Node),
  instructions: List(Instruction),
) -> Int {
  find_number_of_instructions_loop(nodes, "AAA", instructions, instructions, 0)
}

fn get_nodes(lines: List(String)) -> Dict(String, Node) {
  lines
  |> list.drop(1)
  |> list.map(parse_node_line)
  |> dict.from_list
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
  let instructions = lines |> get_instructions
  let nodes = lines |> get_nodes
  let result = instructions |> find_number_of_instructions(nodes, _)
  io.debug(result)
}
