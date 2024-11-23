import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import part_1

// I used some code from part 1

// this function is used in order to correctly manage overlapping cases:
// for example 'sevenine' should be treated as 79, not 77
fn replace_nums(s: String) -> String {
  s
  |> string.replace("one", "o1ne")
  |> string.replace("two", "t2wo")
  |> string.replace("three", "t3hree")
  |> string.replace("four", "f4our")
  |> string.replace("five", "f5ive")
  |> string.replace("six", "s6ix")
  |> string.replace("seven", "s7even")
  |> string.replace("eight", "e8ight")
  |> string.replace("nine", "n9ine")
}

fn extract_number_from_line(line: String) -> Int {
  line
  |> replace_nums
  |> string.to_graphemes
  |> list.map(int.base_parse(_, 10))
  |> result.values
  |> part_1.get_first_and_last
  |> list.map(int.to_string)
  |> string.join("")
  |> int.base_parse(10)
  |> result.unwrap(0)
}

pub fn run() {
  let filepath = "real_input.txt"
  let sum =
    part_1.get_lines(filepath)
    |> list.map(extract_number_from_line)
    |> int.sum
  io.println("Part two result is: " <> int.to_string(sum))
}
