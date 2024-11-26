import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/string
import simplifile

pub type Type =
  Int

const five_kind = 7

const four_kind = 6

const full_house = 5

const three_kind = 4

const two_pair = 3

const one_pair = 2

const high_card = 1

const labels: List(#(String, Int)) = [
  #("A", 13), #("K", 12), #("Q", 11), #("J", 10), #("T", 9), #("9", 8),
  #("8", 7), #("7", 6), #("6", 5), #("5", 4), #("4", 3), #("3", 2), #("2", 1),
]

pub type Hand {
  Hand(cards: String, hand_type: Type, bid: Int)
}

pub fn compare_cards(
  c1: String,
  c2: String,
  labels: List(#(String, Int)),
) -> Order {
  let labels_dict = labels |> dict.from_list
  let v1 = labels_dict |> dict.get(c1) |> result.unwrap(0)
  let v2 = labels_dict |> dict.get(c2) |> result.unwrap(0)
  int.compare(v1, v2)
}

pub fn card_by_card_comparison(
  h1: Hand,
  h2: Hand,
  labels: List(#(String, Int)),
) -> Order {
  h1.cards
  |> string.to_graphemes
  |> list.zip(h2.cards |> string.to_graphemes)
  |> list.drop_while(fn(tuple) { tuple.0 == tuple.1 })
  |> list.first
  |> result.unwrap(#("1", "1"))
  |> fn(t: #(String, String)) { compare_cards(t.0, t.1, labels) }
}

fn compare_hands(h1: Hand, h2: Hand) -> Order {
  case h1.hand_type, h2.hand_type {
    a, b if a == b -> card_by_card_comparison(h1, h2, labels)
    _, _ -> int.compare(h1.hand_type, h2.hand_type)
  }
}

pub fn count_cards(cards: String) -> List(#(String, Int)) {
  cards
  |> string.to_graphemes
  |> list.map(fn(card) { dict.from_list([#(card, 1)]) })
  |> list.fold(dict.new(), fn(d1, d2) {
    dict.combine(d1, d2, fn(count_1, count_2) { count_1 + count_2 })
  })
  |> dict.to_list
}

fn count_to_type(count: List(#(String, Int))) -> Type {
  let sorted_count = count |> list.map(fn(t) { t.1 }) |> list.sort(int.compare)
  case sorted_count {
    [5] -> five_kind
    [1, 4] -> four_kind
    [2, 3] -> full_house
    [1, 1, 3] -> three_kind
    [1, 2, 2] -> two_pair
    [1, 1, 1, 2] -> one_pair
    _ -> high_card
  }
}

pub fn cards_to_type(cards: String) -> Type {
  cards |> count_cards |> count_to_type
}

pub fn parse_line(line: String) -> Hand {
  let assert Ok(cards) = line |> string.split(" ") |> list.first
  let assert Ok(bid) =
    line
    |> string.split(" ")
    |> list.last
    |> result.try(fn(bid) { bid |> string.trim |> int.base_parse(10) })
  Hand(cards, cards_to_type(cards), bid)
}

pub fn get_lines(filepath: String) -> List(String) {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(s) { !string.is_empty(s) })
}

pub fn run() {
  let result =
    get_lines("real_input.txt")
    |> list.map(parse_line)
    |> list.sort(compare_hands)
    |> list.index_fold(0, fn(acc, hand, i) { acc + hand.bid * { i + 1 } })
  io.println("Result for part 1 is: " <> int.to_string(result))
}
