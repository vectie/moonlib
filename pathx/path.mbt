///|
using @xpath {type Path}

///|
fn StringView::end_offset(self : StringView) -> Int32 {
  self.start_offset() + self.length()
}

///|
/// Path component separator
pub let sep : Char = '/'

///|
/// Return the directory name of path.
/// 
/// This behavior is similar to Python `os.path.dirname`, but inconsistent with Posix convention dirname command.
/// 
/// edge cases: when path is relative path without directory component, return "."
pub fn dirname(path : StringView) -> StringView {
  let trimmed = path.trim_end(chars="/")
  if trimmed.is_empty() {
    return if path.is_empty() { "." } else { path }
  }
  if trimmed.length() != path.length() {
    return trimmed
  }
  match path.rev_find("/") {
    None => "."
    Some(index) => {
      let prefix = path.view(end_offset=index + 1)
      let dir = prefix.trim_end(chars="/")
      if dir.is_empty() {
        prefix
      } else {
        dir
      }
    }
  }
}

///|
/// Return the basename of path 
/// 
/// 1. first trim trailing `/` if not root `/`
/// 2. extract last component after last `/`
/// 
/// This behavior is consistent with Posix convention basename command, but inconsistent with Python `os.path.basename`
/// 
pub fn basename(path : StringView) -> StringView {
  let trimmed = path.trim_end(chars="/")
  if trimmed.is_empty() && !path.is_empty() {
    return path.view(end_offset=1)
  }
  fn scan(current : StringView) -> StringView {
    match current {
      [] => trimmed
      [.., '/'] as view => trimmed.view(start_offset=view.end_offset())
      [.. view, _] => scan(view)
    }
  }
  scan(trimmed)
}

///|
/// Extract extension name include `.`
/// 
/// property: `stem(path) + ext(path) == basename(path)`
pub fn ext(path : StringView) -> StringView {
  Path::extname(path.to_owned())
}

///|
/// replace extension name with `ext`, if basename exists.
/// 
/// failed cases: 
/// If `basename(path)` is empty, `.`, `..`, or the root `/`, return the
/// original path: none of these names has an extension to replace.
/// 
/// This API is not consistent with Python `pathlib.Path.with_suffix`, which would raise exception in failed cases.
/// 
pub fn replace_ext(path : StringView, ext : StringView) -> String {
  let basename = basename(path)
  match basename {
    "" | "." | ".." | "/" => path.to_owned()
    _ => {
      let old_ext_len = match basename.rev_find(".") {
        None | Some(0) => 0
        Some(idx) => basename.length() - idx
      }
      let directory_stem = path.view(
        start_offset=0,
        end_offset=path.length() - old_ext_len,
      )
      let buffer = StringBuilder(
        size_hint=(directory_stem.length() + ext.length()) << 1,
      )
      buffer.write_stringview(directory_stem)
      buffer.write_stringview(ext)
      buffer.to_string()
    }
  }
}

///|
/// Extract stem part exclude `.`
/// 
/// property: `stem(path) + ext(path) == basename(path)`
pub fn stem(path : StringView) -> StringView {
  let base = basename(path)
  let ext = ext(path)
  base.view(start_offset=0, end_offset=base.length() - ext.length())
}

///|
priv enum SplitState {
  Root
  Segment
}

///|
fn skip_redundant_slashes(rest : StringView) -> StringView {
  for current = rest {
    match current {
      ['/', .. next] => continue next
      _ => break current
    }
  }
}

///|
fn split_next_segment(last : StringView) -> (StringView?, StringView) {
  for current = last.view() {
    match current {
      ['/', .. rest] as view => {
        let part = last
          .data()
          .view(
            start_offset=last.start_offset(),
            end_offset=view.start_offset(),
          )
        break (Some(part), skip_redundant_slashes(rest))
      }
      [_, .. rest] => continue rest
      [] as view =>
        if last.is_empty() {
          break (None, view)
        } else {
          break (Some(last), view)
        }
    }
  }
}

///|
/// Split each path component, handle redundant slashes but doesn't resolve `.` and `..`.
pub fn split(view : StringView) -> Iter[StringView] {
  let mut state : SplitState = Root
  let mut last = view
  Iter::new(() => {
    for ;; {
      match state {
        Root =>
          match view {
            // More than 3 slashes are treated as single slash.
            [.. "///", .. rest] => {
              // Skip all redundant slashes.
              last = skip_redundant_slashes(rest)
              state = Segment
              break Some("/")
            }
            [.. "//", .. rest] => {
              state = Segment
              last = rest
              break Some("//")
            }
            ['/', .. rest] => {
              state = Segment
              last = rest
              break Some("/")
            }
            rest => {
              state = Segment
              last = rest
              continue
            }
          }
        Segment => {
          let (part, next) = split_next_segment(last)
          last = next
          break part
        }
      }
    }
  })
}

///|
/// Normalize path by resolving `.` and `..` and eliminating redundant slashes.
pub fn normalize(view : StringView) -> String {
  let mut root = ""
  let components : Array[String] = []
  for part in split(view) {
    if root.is_empty() && components.is_empty() && (part == "/" || part == "//") {
      root = part.to_owned()
    } else if part == "." {
      continue
    } else if part == ".." {
      if !components.is_empty() && components[components.length() - 1] != ".." {
        components.pop() |> ignore
      } else if root.is_empty() {
        components.push("..")
      }
    } else {
      components.push(part.to_owned())
    }
  }
  root + components.join("/")
}

///|
/// 1. normalize path.
/// 2. if rhs is absolute path, return rhs.
pub fn join(p : StringView, q : StringView) -> String {
  if is_absolute(q) {
    normalize(q)
  } else if p.is_empty() {
    normalize(q)
  } else if q.is_empty() {
    normalize(p)
  } else if p.has_suffix("/") {
    normalize(p.to_owned() + q.to_owned())
  } else {
    normalize(p.to_owned() + "/" + q.to_owned())
  }
}

///|
pub fn is_absolute(path : StringView) -> Bool {
  Path::is_absolute(path.to_owned())
}

///|
pub fn is_relative(path : StringView) -> Bool {
  !is_absolute(path)
}

///|
/// Return relative path from `from` to `to`, `from` treated as current working directory.
///
/// property: `join(from, relative(from, to)) == resolve(to)`
/// 
/// join already normalizes the path, so no need to normalize here.
/// 
/// edge cases: when from is equal to to, return "."
pub fn relative(from : StringView, to : StringView) -> String raise {
  let result = Path::relative(to.to_owned(), base=from.to_owned()).0
  if result.is_empty() {
    "."
  } else {
    result
  }
}

///|
/// Resolve relative path to absolute path.
/// 
/// 1. if absolute path is given, normalize and return it.
/// 2. if relative path is given, join it with current working directory,
pub fn resolve(view : StringView) -> String raise {
  Path::resolve(view.to_owned()).0
}
