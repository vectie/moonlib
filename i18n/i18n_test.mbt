///|
test "locale parser canonicalizes supported BCP 47 forms" {
  assert_true(@i18n.parse_locale("en") is Some(EnUs))
  assert_true(@i18n.parse_locale("en_GB") is Some(EnUs))
  assert_true(@i18n.parse_locale("zh-CN") is Some(ZhHans))
  assert_true(@i18n.parse_locale("zh_Hans_CN") is Some(ZhHans))
  assert_true(@i18n.parse_locale("zh-Hant") is None)
  assert_true(@i18n.parse_locale("fr-FR") is None)
}

///|
test "system preference resolves detected locale with English fallback" {
  assert_true(@i18n.resolve_locale(System, "zh-CN") is ZhHans)
  assert_true(@i18n.resolve_locale(System, "de-DE") is EnUs)
  assert_true(@i18n.resolve_locale(Explicit(EnUs), "zh-CN") is EnUs)
}

///|
test "catalog falls back to English and interpolates named values" {
  let catalog = @i18n.Catalog::new(
    "moonbook",
    { "save": "Save", "found": "Found {count} pages" },
    { "save": "保存" },
  )
  assert_eq(catalog.message(ZhHans, "save"), "保存")
  assert_eq(catalog.message(ZhHans, "found"), "Found {count} pages")
  assert_eq(catalog.format(EnUs, "found", { "count": "3" }), "Found 3 pages")
  let missing = catalog.missing_keys(ZhHans)
  assert_true(missing.length() == 1 && missing[0] == "found")
}

///|
test "product override wins over suite interface preference" {
  let preferences : @i18n.LanguagePreferences = {
    interface_locale: "zh-Hans",
    assistant_language: "auto",
    default_document_language: "auto",
    product_locale_overrides: { "moonrobo": "en-US" },
  }
  assert_true(preferences.resolve_interface_locale("moonrobo", "zh-CN") is EnUs)
  assert_true(
    preferences.resolve_interface_locale("moondesk", "en-US") is ZhHans,
  )
}
