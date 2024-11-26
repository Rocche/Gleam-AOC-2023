import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/yielder
import part_1.{type Mapping}

fn revert_mapping(mapping: Mapping) -> Mapping {
  part_1.Mapping(mapping.source_start, mapping.dest_start, mapping.range_len)
}

fn revert_mappings(mappings: List(List(Mapping))) -> List(List(Mapping)) {
  mappings
  |> list.map(fn(cat_maps) { cat_maps |> list.map(revert_mapping) })
  |> list.reverse
}

fn get_min_max_seed(seeds: List(Int)) -> #(Int, Int) {
  let min =
    seeds
    |> list.sized_chunk(2)
    |> list.map(fn(chunk) {
      let assert Ok(start_seed) = chunk |> list.first
      start_seed
    })
    |> list.reduce(int.min)
    |> result.unwrap(0)
  let max =
    seeds
    |> list.sized_chunk(2)
    |> list.map(fn(chunk) {
      let assert Ok(start_seed) = chunk |> list.first
      let assert Ok(n_seeds) = chunk |> list.last
      start_seed + n_seeds
    })
    |> list.fold(0, int.max)
  #(min, max)
}

fn is_seed_in_seeds(seed: Int, seeds: List(Int)) -> Bool {
  seeds
  |> list.sized_chunk(2)
  |> list.map(fn(chunk) {
    let assert Ok(start_seed) = chunk |> list.first
    let assert Ok(n_seeds) = chunk |> list.last
    #(start_seed, n_seeds)
  })
  |> list.any(fn(seed_pair) {
    seed >= pair.first(seed_pair)
    && seed <= pair.first(seed_pair) + pair.second(seed_pair)
  })
}

pub fn run() {
  // not so elegant solution unfortunately
  let lines = part_1.get_lines("real_input.txt")
  let seeds =
    lines
    |> part_1.get_seeds
  let #(_, max_seed) =
    seeds
    |> get_min_max_seed
  let mappings =
    lines
    |> part_1.get_chain_of_mappings
  let rev_mappings =
    mappings
    |> revert_mappings
  let result =
    yielder.range(1, max_seed)
    |> yielder.drop_while(fn(loc) {
      loc
      |> part_1.get_location_for_seed(rev_mappings)
      |> is_seed_in_seeds(seeds)
      |> bool.negate
    })
    |> yielder.first
    |> result.unwrap(0)
  io.println("Part 2 result is: " <> int.to_string(result))
}
