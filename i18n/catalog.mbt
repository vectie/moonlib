///|
/// Product-owned messages for the two currently supported suite locales.
pub(all) struct Catalog {
  product_id : String
  en_us : Map[String, String]
  zh_hans : Map[String, String]
}

///|
pub fn Catalog::new(
  product_id : String,
  en_us : Map[String, String],
  zh_hans : Map[String, String],
) -> Catalog {
  { product_id, en_us, zh_hans }
}

///|
pub fn Catalog::product_id(self : Catalog) -> String {
  self.product_id
}

///|
pub fn Catalog::message(
  self : Catalog,
  locale : Locale,
  key : StringView,
) -> String {
  let key_string = key.to_owned()
  match locale {
    ZhHans =>
      match self.zh_hans.get_from_string(key) {
        Some(message) => message
        None => self.en_us.get_from_string(key).unwrap_or(key_string)
      }
    EnUs => self.en_us.get_from_string(key).unwrap_or(key_string)
  }
}

///|
/// Interpolates named `{placeholder}` values after locale fallback. Products
/// should expose generated typed wrappers rather than calling this directly.
pub fn Catalog::format(
  self : Catalog,
  locale : Locale,
  key : StringView,
  args : Map[String, String],
) -> String {
  let mut message = self.message(locale, key)
  args.each(fn(name, value) {
    message = message.replace_all(old="{" + name + "}", new=value)
  })
  message
}

///|
pub fn Catalog::missing_keys(self : Catalog, locale : Locale) -> Array[String] {
  let translated = match locale {
    EnUs => self.en_us
    ZhHans => self.zh_hans
  }
  let missing : Array[String] = []
  self.en_us.each(fn(key, _) {
    if !translated.contains(key) {
      missing.push(key)
    }
  })
  missing
}
