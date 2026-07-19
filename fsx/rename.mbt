///|
#borrow(source, destination)
extern "c" fn fsx_rename(source : Bytes, destination : Bytes) -> Int = "moonbit_moonlib_fsx_rename"

///|
/// Atomically replace `destination` with `source` when both paths reside on the
/// same POSIX filesystem. On failure, the source remains available for recovery.
pub fn atomic_rename(source : String, destination : String) -> Unit raise {
  let ret = fsx_rename(
    @encoding/utf8.encode(source),
    @encoding/utf8.encode(destination),
  )
  if ret == -1 {
    raise @errno.Errno(@errno.get())
  }
}
