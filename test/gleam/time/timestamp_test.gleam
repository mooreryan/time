import gleam/order
import gleam/time/duration
import gleam/time/timestamp
import gleeunit/should

pub fn compare_0_test() {
  timestamp.compare(
    timestamp.from_unix_seconds(1),
    timestamp.from_unix_seconds(1),
  )
  |> should.equal(order.Eq)
}

pub fn compare_1_test() {
  timestamp.compare(
    timestamp.from_unix_seconds(2),
    timestamp.from_unix_seconds(1),
  )
  |> should.equal(order.Gt)
}

pub fn compare_2_test() {
  timestamp.compare(
    timestamp.from_unix_seconds(2),
    timestamp.from_unix_seconds(3),
  )
  |> should.equal(order.Lt)
}

pub fn difference_0_test() {
  timestamp.difference(
    timestamp.from_unix_seconds(1),
    timestamp.from_unix_seconds(1),
  )
  |> should.equal(duration.seconds(0))
}

pub fn difference_1_test() {
  timestamp.difference(
    timestamp.from_unix_seconds(1),
    timestamp.from_unix_seconds(5),
  )
  |> should.equal(duration.seconds(4))
}

pub fn difference_2_test() {
  timestamp.difference(
    timestamp.from_unix_seconds_and_nanoseconds(1, 10),
    timestamp.from_unix_seconds_and_nanoseconds(5, 20),
  )
  |> should.equal(duration.seconds(4) |> duration.add(duration.nanoseconds(10)))
}

pub fn add_0_test() {
  timestamp.from_unix_seconds(0)
  |> timestamp.add(duration.seconds(1))
  |> should.equal(timestamp.from_unix_seconds(1))
}

pub fn add_1_test() {
  timestamp.from_unix_seconds(100)
  |> timestamp.add(duration.seconds(-1))
  |> should.equal(timestamp.from_unix_seconds(99))
}

pub fn add_2_test() {
  timestamp.from_unix_seconds(99)
  |> timestamp.add(duration.nanoseconds(100))
  |> should.equal(timestamp.from_unix_seconds_and_nanoseconds(99, 100))
}

pub fn to_unix_seconds_0_test() {
  timestamp.from_unix_seconds_and_nanoseconds(1, 0)
  |> timestamp.to_unix_seconds
  |> should.equal(1.0)
}

pub fn to_unix_seconds_1_test() {
  timestamp.from_unix_seconds_and_nanoseconds(1, 500_000_000)
  |> timestamp.to_unix_seconds
  |> should.equal(1.5)
}

pub fn to_unix_seconds_and_nanoseconds_0_test() {
  timestamp.from_unix_seconds_and_nanoseconds(1, 0)
  |> timestamp.to_unix_seconds_and_nanoseconds
  |> should.equal(#(1, 0))
}

pub fn to_unix_seconds_and_nanoseconds_1_test() {
  timestamp.from_unix_seconds_and_nanoseconds(1, 2)
  |> timestamp.to_unix_seconds_and_nanoseconds
  |> should.equal(#(1, 2))
}

pub fn system_time_0_test() {
  let #(now, _) =
    timestamp.system_time() |> timestamp.to_unix_seconds_and_nanoseconds

  // This test will start to fail once enough time has passed.
  // When that happens please update these values.
  let when_this_test_was_last_updated = 1_735_307_287
  let christmas_day_2025 = 1_766_620_800

  let assert True = now > when_this_test_was_last_updated
  let assert True = now < christmas_day_2025
}