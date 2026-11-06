# MoonLib handoff notes

Work on main unless the user requests a branch. Keep public interfaces stable
for a bug fix and preserve unrelated working-tree edits.

## Basename peer-task comparison 2026-11-06

- Coordinator added three failing assertions in the existing basename test:
  docs/// -> docs, 资料/// -> 资料, / -> /. MoonCode on the complete main
  repository authored the implementation, preserved empty/file/single-slash
  and existing multi-root behavior, and kept replace_ext slash-only paths
  unchanged. Three model edits and two post-edit regression failures, then
  actual Native pathx 12/12 and full 108/108; no manual business rewrite.
- First trial exposed opaque timeout-policy errors in Claw/Fort; one runtime
  repair/restart resumed it. Cost 918024 input / 5404 output, 499.657 sec.
  Saved that delivered file, restored only original implementation and reran
  identical prompt/assertions after diagnostic fix. Final delivered file is
  from this second run, not the saved first patch. No in-run intervention;
  16 responses, 382588 input (cached 29568) / 2620 output, 235.327 sec.
- Independent final Native 108/108 and pathx JS 12/12. Public API unchanged;
  info/fmt/whitespace checked. Full audit, both costs and remaining snapshot
  executable-mode noise are in sibling MoonDesk:
  docs/MOONCODE_TOKEN_AUDIT_2026-11-06.md. The evaluation daemon is stopped;
  .moonsuite evidence stays out of Git. Cash fees unknown.

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
