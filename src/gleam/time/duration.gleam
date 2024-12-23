import gleam/int
import gleam/order

// TODO: document
pub opaque type Duration {
  // When compiling to JavaScript ints have limited precision and size. This
  // means that if we were to store the the timestamp in a single int the
  // duration would not be able to represent very large or small durations.
  // Durations are instead represented as a number of seconds and a number of
  // nanoseconds.
  //
  // If you have manually adjusted the seconds and nanoseconds values the
  // `normalise` function can be used to ensure the time is represented the
  // intended way, with `nanoseconds` being positive and less than 1 second.
  Duration(seconds: Int, nanoseconds: Int)
}

/// Ensure the duration is represented with `nanoseconds` being positive and
/// less than 1 second.
///
/// This function does not change the amount of time that the duratoin refers
/// to, it only adjusts the values used to represent the time.
///
fn normalise(duration: Duration) -> Duration {
  let multiplier = 1_000_000_000
  let nanoseconds = duration.nanoseconds % multiplier
  let overflow = duration.nanoseconds - nanoseconds
  let seconds = duration.seconds + overflow / multiplier
  Duration(seconds, nanoseconds)
}

// TODO: docs
pub fn compare(left: Duration, right: Duration) -> order.Order {
  order.break_tie(
    int.compare(left.seconds, right.seconds),
    int.compare(left.nanoseconds, right.nanoseconds),
  )
}

// TODO: docs
// TODO: test
pub fn difference(left: Duration, right: Duration) -> Duration {
  todo
}

// TODO: docs
pub fn add(left: Duration, right: Duration) -> Duration {
  Duration(left.seconds + right.seconds, left.nanoseconds + right.nanoseconds)
  |> normalise
}

// TODO: docs
// TODO: test
pub fn to_iso8601_string(duration: Duration) -> String {
  todo
}

// TODO: docs
pub fn seconds(amount: Int) -> Duration {
  Duration(amount, 0) |> normalise
}

// TODO: docs
// TODO: test
pub fn milliseconds(amount: Int) -> Duration {
  let remainder = amount % 1000
  let overflow = amount - remainder
  let nanoseconds = remainder * 1_000_000
  let seconds = overflow / 1000
  Duration(seconds, nanoseconds)
}

// TODO: docs
pub fn nanoseconds(amount: Int) -> Duration {
  Duration(0, amount)
  |> normalise
}

// TODO: docs
pub fn to_seconds(duration: Duration) -> Float {
  let seconds = int.to_float(duration.seconds)
  let nanoseconds = int.to_float(duration.nanoseconds)
  seconds +. { nanoseconds /. 1_000_000_000.0 }
}
