# MoonLib handoff notes

Work on main unless the user requests a branch. Keep public interfaces stable
for a bug fix and preserve unrelated working-tree edits.

## Actual MoonCode Native delivery 2026-11-06

- MoonCode worked directly in this complete Git checkout, not a core package
  copy. Fixed replace_ext for dotfiles by treating a leading dot as part of
  the name. Coordinator supplied .env/.gitignore failing assertions; model
  added hidden-name-with-suffix assertions. Final implementation was accepted
  without manual revision.
- The tested async/fs tmpdir uses host /tmp regardless of TMPDIR. Five real
  sandbox failures were fixed only in test fixtures using existing
  fsx.mkdtemp + os.tmpdir, with one test-only os import; no new library API.
- Native commands in a private executor HOME need explicit Moon SDK registry
  and direct CLT compiler/ar/SDK environment. See
  ../moonfort/docs/EXECUTOR_CONFIG.md for the existing Shell command. Shell
  assignments do not configure a later semantic moon_cmd invocation.
- Full-repository Native 108/108 and pathx JS 12/12 passed independently. Model
  final run also passed Native 12/12 and full 108/108 before finish. Two earlier
  attempts were cancelled for deployment/runtime problems, not counted as
  successful deliveries. Full record:
  ../moondesk/docs/MOONCODE_LIVE_NATIVE_REPOSITORY_2026-11-06.md.
- All attempts: 49 observed responses, input 2294816 (cached 739712), output
  6350; final attempt 104.580 sec, first submission to final finish 977.635 sec.
  Cash cost unknown. Final run had no in-run steering, business patch or test
  takeover; do not hide earlier coordinator intervention or infer general
  success rates. LocalOs/Degraded, not a full production-isolation claim.
- .moonsuite contains local run evidence; excluded via .git/info/exclude and
  never committed. The evaluation daemon was stopped. Keep journal facts and
  credential-bearing deployment configuration out of Git.
