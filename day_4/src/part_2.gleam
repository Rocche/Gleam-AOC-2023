import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import part_1

pub type Scratchcard {
  Scratchcard(id: Int, winning: List(Int), got: List(Int))
}

fn parse_line(line: String) -> Scratchcard {
  let #(winning_nums, got_nums) = part_1.parse_line(line)
  let id =
    line
    |> string.trim
    |> string.split(": ")
    |> list.first
    |> result.try(fn(s) {
      s |> string.replace("Card", "") |> string.trim |> int.base_parse(10)
    })
    |> result.unwrap(0)
  Scratchcard(id, winning_nums, got_nums)
}

fn scratchcards_to_dict(
  cards: List(Scratchcard),
) -> Dict(Int, #(Scratchcard, Int)) {
  cards
  |> list.map(fn(c) { #(c.id, #(c, 1)) })
  |> dict.from_list
}

fn produce_scratchcards_loop(
  id: Int,
  cards: Dict(Int, #(Scratchcard, Int)),
) -> Dict(Int, #(Scratchcard, Int)) {
  case cards |> dict.get(id) {
    Error(Nil) -> cards
    Ok(card_record) -> {
      let #(card, count) = card_record
      let winning_nums = part_1.count_winning_numbers(card.winning, card.got)
      case winning_nums {
        0 -> produce_scratchcards_loop(id + 1, cards)
        n_win -> {
          let additional_cards =
            list.range(id + 1, id + n_win)
            |> dict.take(cards, _)
            |> dict.map_values(fn(_, card_count) { #(card_count.0, count) })
          produce_scratchcards_loop(
            id + 1,
            dict.combine(cards, additional_cards, fn(a, b) { #(a.0, a.1 + b.1) }),
          )
        }
      }
    }
  }
}

fn count_scratchcards(cards: List(Scratchcard)) -> Int {
  cards
  |> scratchcards_to_dict
  |> produce_scratchcards_loop(1, _)
  |> dict.to_list
  |> list.map(fn(record) { { record.1 }.1 })
  |> int.sum
}

pub fn run() {
  let result =
    part_1.get_lines("real_input.txt")
    |> list.map(parse_line)
    |> count_scratchcards
  io.println("Part 1 result is: " <> int.to_string(result))
}
