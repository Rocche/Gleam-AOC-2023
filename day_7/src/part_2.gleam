import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/string
import part_1.{type Hand}

const labels: List(#(String, Int)) = [
  #("A", 13), #("K", 12), #("Q", 11), #("T", 10), #("9", 9), #("8", 8),
  #("7", 7), #("6", 6), #("5", 5), #("4", 4), #("3", 3), #("2", 2), #("J", 1),
]

fn compare_counts(count_1: #(String, Int), count_2: #(String, Int)) -> Order {
  case int.compare(count_1.1, count_2.1) {
    order.Eq -> part_1.compare_cards(count_1.0, count_2.0, labels)
    comp -> comp
  }
}

fn transform_jokers(cards: String) -> String {
  let count = part_1.count_cards(cards) |> dict.from_list
  case dict.get(count, "J") {
    Error(Nil) -> cards
    Ok(5) -> cards
    Ok(j_count) -> {
      let assert Ok(#(highest_count, rest)) =
        count
        |> dict.filter(fn(card, _) { card != "J" })
        |> dict.to_list
        |> list.sort(fn(c1, c2) { order.negate(compare_counts(c1, c2)) })
        |> list.pop(fn(_) { True })
      [#(highest_count.0, highest_count.1 + j_count), ..rest]
      |> list.map(fn(tuple) { string.repeat(tuple.0, tuple.1) })
      |> string.join("")
    }
  }
}

fn compare_hands(h1: Hand, h2: Hand) -> Order {
  let cards_1_joker_type = h1.cards |> transform_jokers |> part_1.cards_to_type
  let cards_2_joker_type = h2.cards |> transform_jokers |> part_1.cards_to_type
  case cards_1_joker_type, cards_2_joker_type {
    a, b if a == b -> part_1.card_by_card_comparison(h1, h2, labels)
    _, _ -> int.compare(cards_1_joker_type, cards_2_joker_type)
  }
}

pub fn run() {
  let result =
    part_1.get_lines("real_input.txt")
    |> list.map(part_1.parse_line)
    |> list.sort(compare_hands)
    |> list.index_fold(0, fn(acc, hand, i) { acc + hand.bid * { i + 1 } })
  io.println("Result for part 2 is: " <> int.to_string(result))
}
