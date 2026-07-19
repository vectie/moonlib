///|
/// User-level language preferences shared by Moon Suite products. Interface,
/// assistant response, and document language are deliberately independent.
pub(all) struct LanguagePreferences {
  interface_locale : String
  assistant_language : String
  default_document_language : String
  product_locale_overrides : Map[String, String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn default_language_preferences() -> LanguagePreferences {
  {
    interface_locale: "system",
    assistant_language: "auto",
    default_document_language: "auto",
    product_locale_overrides: {},
  }
}

///|
pub fn LanguagePreferences::interface_preference(
  self : LanguagePreferences,
  product_id : StringView,
) -> LocalePreference {
  let configured = self.product_locale_overrides
    .get_from_string(product_id)
    .unwrap_or(self.interface_locale)
  parse_preference(configured).unwrap_or(System)
}

///|
pub fn LanguagePreferences::resolve_interface_locale(
  self : LanguagePreferences,
  product_id : StringView,
  detected_locale : StringView,
) -> Locale {
  resolve_locale(self.interface_preference(product_id), detected_locale)
}
