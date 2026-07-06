///|
struct Epoch {
  marker : Unit
}

///|
pub let epoch : Epoch = { marker: () }

///|
pub impl Clock for Epoch with fn now(clock : Epoch) -> Timestamp {
  let _ = clock.marker
  Timestamp::from_ms(@async.now())
}

///|
pub impl Clock for Epoch with fn now_str(clock : Epoch) -> String {
  let _ = clock.marker
  @time.unix(clock.now().truncate_to_s()).to_plain_date_time().to_string() catch {
    err => "Time error: \{err}"
  }
}

///|
pub(open) trait Clock {
  fn now(self : Self) -> Timestamp
  fn now_str(self : Self) -> String
}
