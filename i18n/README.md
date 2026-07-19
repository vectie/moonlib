# Moon Suite internationalization

`vectie/moonlib/i18n` defines the suite locale and preference contracts. Each
product owns `locales/en-US.json` and `locales/zh-Hans.json`, then generates a
self-contained adapter for its frontend/runtime. This keeps product releases
independent while giving every adapter the same fallback behavior.

Catalog keys are semantic and stable. English text is never used as an id.
Arguments use named `{placeholders}` and must match in every locale. Validate
catalogs with `scripts/check-i18n-catalogs.mjs`.

Interface language, assistant response language, and document language are
separate preferences. Protocol values, routes, enum keys, storage paths, and
diagnostic details are not translated; presentation adapters translate typed
states at the UI boundary.

Web surfaces should migrate from compatibility text matching to semantic
attributes:

```html
<button data-i18n="common.refresh">Refresh</button>
<span data-i18n="status.updated"
      data-i18n-params='{"time":"10:30"}'>Updated 10:30</span>
```

Use `data-i18n-placeholder`, `data-i18n-title`, and `data-i18n-aria-label` for
localized attributes. Mark authored material with
`data-i18n-scope="content"` and raw identifiers, logs, evidence, or protocol
values with `data-i18n-scope="technical"`. These scopes are never translated.

For dynamic strings, call
`window.MoonSuiteI18n.message(key, parameters)` at the presentation boundary.
The generated adapter also observes later text and accessibility-attribute
updates so asynchronous UI state cannot revert to English.

Run both checks before publishing generated assets:

```sh
node --test scripts/generate-web-i18n.test.mjs
node scripts/check-i18n-catalogs.mjs <product-locales-dir> [...]
```
