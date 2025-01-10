import gleam/int
import gleam/option
import gleam/string
import qcheck

pub fn date_time_generator(
  with_leap_second with_leap_second: Bool,
  secfrac_spec secfrac_spec: SecfracSpec,
) -> qcheck.Generator(String) {
  use full_date, t, full_time <- qcheck.map3(
    g1: full_date_generator(),
    g2: t_generator(),
    g3: full_time_generator(with_leap_second, secfrac_spec),
  )
  full_date <> t <> full_time
}

pub fn date_time_no_secfrac_generator(
  with_leap_second with_leap_second: Bool,
) -> qcheck.Generator(String) {
  use full_date, t, full_time <- qcheck.map3(
    g1: full_date_generator(),
    g2: t_generator(),
    g3: full_time_no_secfrac_generator(with_leap_second),
  )
  full_date <> t <> full_time
}

fn full_date_generator() -> qcheck.Generator(String) {
  use date_fullyear <- qcheck.bind(date_fullyear_generator())
  use date_month <- qcheck.bind(date_month_generator())
  use date_mday <- qcheck.map(date_mday_generator(
    year: date_fullyear,
    month: date_month,
  ))
  date_fullyear <> "-" <> date_month <> "-" <> date_mday
}

fn date_fullyear_generator() -> qcheck.Generator(String) {
  zero_padded_digits_generator(length: 4, from: 0, to: 9999)
}

fn date_month_generator() -> qcheck.Generator(String) {
  zero_padded_digits_generator(length: 2, from: 1, to: 12)
}

fn date_mday_generator(
  year year: String,
  month month: String,
) -> qcheck.Generator(String) {
  let is_leap_year = is_leap_year(year)

  case month {
    "01" | "03" | "05" | "07" | "08" | "10" | "12" ->
      zero_padded_digits_generator(length: 2, from: 1, to: 31)
    "04" | "06" | "09" | "11" ->
      zero_padded_digits_generator(length: 2, from: 1, to: 30)
    "02" if is_leap_year ->
      zero_padded_digits_generator(length: 2, from: 1, to: 29)
    "02" -> zero_padded_digits_generator(length: 2, from: 1, to: 28)
    _ -> panic as { "date_mday_generator: bad month " <> month }
  }
}

// Implementation from RFC 3339 Appendix C
fn is_leap_year(year_input: String) -> Bool {
  let assert 4 = string.length(year_input)
  let assert Ok(year) = int.parse(year_input)

  let result = year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }

  result
}

fn t_generator() {
  qcheck.from_generators([qcheck.return("T"), qcheck.return("t")])
}

fn full_time_generator(
  with_leap_second with_leap_second: Bool,
  secfrac_spec secfrac_spec: SecfracSpec,
) -> qcheck.Generator(String) {
  use partial_time, time_offset <- qcheck.map2(
    g1: partial_time_generator(with_leap_second, secfrac_spec),
    g2: time_offset_generator(),
  )
  partial_time <> time_offset
}

fn full_time_no_secfrac_generator(
  with_leap_second with_leap_second: Bool,
) -> qcheck.Generator(String) {
  use partial_time, time_offset <- qcheck.map2(
    g1: partial_time_no_secfrac_generator(with_leap_second),
    g2: time_offset_generator(),
  )
  partial_time <> time_offset
}

fn partial_time_generator(
  with_leap_second with_leap_second: Bool,
  secfrac_spec secfrac_spec: SecfracSpec,
) -> qcheck.Generator(String) {
  qcheck.return({
    use time_hour <- qcheck.parameter
    use time_minute <- qcheck.parameter
    use time_second <- qcheck.parameter
    use optional_time_secfrac <- qcheck.parameter
    time_hour
    <> ":"
    <> time_minute
    <> ":"
    <> time_second
    <> unwrap_optional_string(optional_time_secfrac)
  })
  |> qcheck.apply(time_hour_generator())
  |> qcheck.apply(time_minute_generator())
  |> qcheck.apply(time_second_generator(with_leap_second))
  |> qcheck.apply(qcheck.option(time_secfrac_generator(secfrac_spec)))
}

fn partial_time_no_secfrac_generator(with_leap_second with_leap_second: Bool) {
  qcheck.return({
    use time_hour <- qcheck.parameter
    use time_minute <- qcheck.parameter
    use time_second <- qcheck.parameter
    time_hour <> ":" <> time_minute <> ":" <> time_second
  })
  |> qcheck.apply(time_hour_generator())
  |> qcheck.apply(time_minute_generator())
  |> qcheck.apply(time_second_generator(with_leap_second))
}

fn time_hour_generator() -> qcheck.Generator(String) {
  zero_padded_digits_generator(length: 2, from: 0, to: 23)
}

fn time_minute_generator() -> qcheck.Generator(String) {
  zero_padded_digits_generator(length: 2, from: 0, to: 59)
}

fn time_second_generator(
  with_leap_second with_leap_second: Bool,
) -> qcheck.Generator(String) {
  let max_second = case with_leap_second {
    True -> 60
    False -> 59
  }
  zero_padded_digits_generator(length: 2, from: 0, to: max_second)
}

fn zero_padded_digits_generator(
  length length: Int,
  from min: Int,
  to max: Int,
) -> qcheck.Generator(String) {
  use n <- qcheck.map(qcheck.int_uniform_inclusive(min, max))
  int.to_string(n) |> string.pad_start(to: length, with: "0")
}

pub type SecfracSpec {
  Default
  WithMaxLength(Int)
}

fn time_secfrac_generator(secfrac_spec: SecfracSpec) -> qcheck.Generator(String) {
  let generator = case secfrac_spec {
    Default -> one_or_more_digits_generator()
    WithMaxLength(max_count) -> digits_generator(min_count: 1, max_count:)
  }

  use digits <- qcheck.map(generator)
  "." <> digits
}

fn one_or_more_digits_generator() -> qcheck.Generator(String) {
  qcheck.string_non_empty_from(qcheck.char_digit())
}

fn digits_generator(
  min_count min_count: Int,
  max_count max_count: Int,
) -> qcheck.Generator(String) {
  qcheck.string_generic(
    qcheck.char_digit(),
    qcheck.int_uniform_inclusive(min_count, max_count),
  )
}

fn time_offset_generator() -> qcheck.Generator(String) {
  qcheck.from_generators([z_generator(), time_numoffset_generator()])
}

fn z_generator() {
  qcheck.from_generators([qcheck.return("Z"), qcheck.return("z")])
}

fn time_numoffset_generator() -> qcheck.Generator(String) {
  use plus_or_minus, time_hour, time_minute <- qcheck.map3(
    g1: plus_or_minus_generator(),
    g2: time_hour_generator(),
    g3: time_minute_generator(),
  )

  plus_or_minus <> time_hour <> ":" <> time_minute
}

fn plus_or_minus_generator() -> qcheck.Generator(String) {
  qcheck.from_generators([qcheck.return("+"), qcheck.return("-")])
}

fn unwrap_optional_string(optional_string: option.Option(String)) -> String {
  case optional_string {
    option.None -> ""
    option.Some(string) -> string
  }
}
