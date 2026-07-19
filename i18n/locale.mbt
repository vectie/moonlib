///|
/// A concrete locale supported by the Moon Suite interface.
pub(all) enum Locale {
  EnUs
  ZhHans
} derive(Debug, Eq, Compare, Hash)

///|
/// The user's locale choice. `System` delegates to the host/browser locale.
pub(all) enum LocalePreference {
  System
  Explicit(Locale)
} derive(Debug, Eq)

///|
pub fn Locale::tag(self : Locale) -> String {
  match self {
    EnUs => "en-US"
    ZhHans => "zh-Hans"
  }
}

///|
pub fn Locale::html_lang(self : Locale) -> String {
  self.tag()
}

///|
pub fn Locale::direction(self : Locale) -> String {
  match self {
    EnUs | ZhHans => "ltr"
  }
}

///|
pub fn Locale::is_chinese(self : Locale) -> Bool {
  self == ZhHans
}

///|
/// Parses common BCP 47 spellings and applies the suite's supported-locale
/// policy. Regional Simplified Chinese locales resolve to `zh-Hans`.
pub fn parse_locale(raw : StringView) -> Locale? {
  let normalized = raw
    .to_owned()
    .trim()
    .to_owned()
    .replace_all(old="_", new="-")
    .to_lower()
  if normalized == "en" || normalized.has_prefix("en-") {
    Some(EnUs)
  } else if normalized == "zh-hans" ||
    normalized.has_prefix("zh-hans-") ||
    normalized == "zh-cn" ||
    normalized.has_prefix("zh-cn-") ||
    normalized == "zh-sg" ||
    normalized.has_prefix("zh-sg-") {
    Some(ZhHans)
  } else {
    None
  }
}

///|
pub fn parse_preference(raw : StringView) -> LocalePreference? {
  let normalized = raw.to_owned().trim().to_owned().to_lower()
  if normalized == "" || normalized == "system" || normalized == "auto" {
    Some(System)
  } else {
    parse_locale(normalized).map(locale => Explicit(locale))
  }
}

///|
/// Resolves a user preference with a detected host locale and the stable
/// English fallback.
pub fn resolve_locale(
  preference : LocalePreference,
  detected_locale : StringView,
) -> Locale {
  match preference {
    Explicit(locale) => locale
    System => parse_locale(detected_locale).unwrap_or(EnUs)
  }
}

///|
pub fn fallback_locales(locale : Locale) -> Array[Locale] {
  match locale {
    EnUs => [EnUs]
    ZhHans => [ZhHans, EnUs]
  }
}
