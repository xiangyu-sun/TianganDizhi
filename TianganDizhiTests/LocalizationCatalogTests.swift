import ChineseAstrologyCalendar
import Foundation
import Testing
@testable import TianganDizhi

/// The string catalogs use Traditional Chinese literals as keys with `en` as the
/// development language. Every key therefore needs an explicit zh-Hant value:
/// without one, a zh-Hant device falls back to the English value once English
/// ships. Spanish has no fallback worth having either (it would be English), so
/// it needs a value for every key too.
@Suite struct LocalizationCatalogTests {

  // MARK: Internal

  @Test(.enabled(if: sourcesAvailable, "Reads the catalogs from the source checkout"), arguments: catalogPaths)
  func everyKeyHasTraditionalChinese(_ path: String) throws {
    let missing = try entries(in: path)
      .filter { $0.value.shouldTranslate != false }
      .filter { $0.value.localizations?["zh-Hant"]?.stringUnit?.value?.isEmpty ?? true }
      .map(\.key)
      .sorted()
    #expect(missing.isEmpty, "Keys without a zh-Hant value in \(path): \(missing)")
  }

  @Test(.enabled(if: sourcesAvailable, "Reads the catalogs from the source checkout"), arguments: spanishCatalogPaths)
  func everyKeyHasSpanish(_ path: String) throws {
    let missing = try entries(in: path)
      .filter { $0.value.shouldTranslate != false }
      .filter { !($0.value.localizations?["es"]?.isComplete ?? false) }
      .map(\.key)
      .sorted()
    #expect(missing.isEmpty, "Keys without a Spanish value in \(path): \(missing)")
  }

  /// Plural entries must be plural in Spanish too, with both of its forms.
  @Test(.enabled(if: sourcesAvailable, "Reads the catalogs from the source checkout"), arguments: spanishCatalogPaths)
  func spanishKeepsEnglishPluralVariants(_ path: String) throws {
    for (key, entry) in try entries(in: path) {
      guard let english = entry.localizations?["en"], !english.pluralForms.isEmpty else { continue }
      let spanish = entry.localizations?["es"]?.pluralForms ?? []
      #expect(spanish.count == english.pluralForms.count, "\(key)")
      for forms in spanish {
        #expect(Set(forms.keys).isSuperset(of: ["one", "other"]), "\(key)")
      }
    }
  }

  @Test(.enabled(if: sourcesAvailable, "Reads the catalogs from the source checkout"), arguments: catalogPaths)
  func translationsKeepTheKeysPlaceholders(_ path: String) throws {
    for (key, entry) in try entries(in: path) {
      for (language, localization) in entry.localizations ?? [:] {
        // Plural substitutions (`%#@days@`) carry their placeholder in the substitution.
        guard let value = localization.stringUnit?.value, !value.contains("%#@") else { continue }
        #expect(
          Self.placeholders(in: value) == Self.placeholders(in: key),
          "\(language) value \"\(value)\" doesn't use the placeholders of \"\(key)\"")
      }
    }
  }

  @Test func appBundleShipsTraditionalChineseTable() throws {
    let path = try #require(Bundle.main.path(forResource: "zh-Hant", ofType: "lproj"))
    let bundle = try #require(Bundle(path: path))
    #expect(bundle.localizedString(forKey: "節日曆", value: "missing", table: nil) == "節日曆")
  }

  @Test func appBundleShipsSpanishTable() throws {
    let path = try #require(Bundle.main.path(forResource: "es", ofType: "lproj"))
    let bundle = try #require(Bundle(path: path))
    #expect(bundle.localizedString(forKey: "節日曆", value: "missing", table: nil) == "Calendario festivo")
  }

  @Test(arguments: [
    (DisplayLanguage.zhHans, DisplayLanguage.zhHans),
    (.zhHant, .zhHant),
    (.en, .zhHant),
    (.ru, .zhHant),
  ])
  func glyphsUseSimplifiedOnlyForSimplifiedChinese(_ language: DisplayLanguage, _ expected: DisplayLanguage) {
    #expect(language.glyphLanguage == expected)
  }

  // MARK: Private

  private struct Catalog: Decodable {
    let strings: [String: Entry]
  }

  private struct Entry: Decodable {
    let shouldTranslate: Bool?
    let localizations: [String: Localization]?
  }

  private struct StringUnit: Decodable {
    let value: String?
  }

  private struct Variant: Decodable {
    let stringUnit: StringUnit?
  }

  private struct Variations: Decodable {
    let plural: [String: Variant]?
  }

  private struct Substitution: Decodable {
    let variations: Variations?
  }

  private struct Localization: Decodable {
    let stringUnit: StringUnit?
    let variations: Variations?
    let substitutions: [String: Substitution]?

    /// The plural forms of the string itself and of each of its substitutions.
    var pluralForms: [[String: Variant]] {
      ([variations] + (substitutions ?? [:]).values.map(\.variations)).compactMap { $0?.plural }
    }

    /// Whether there is text, either plain or for every plural form.
    var isComplete: Bool {
      let units = [stringUnit].compactMap { $0 } + pluralForms.flatMap { $0.values.compactMap(\.stringUnit) }
      return !units.isEmpty && units.allSatisfy { !($0.value?.isEmpty ?? true) }
    }
  }

  private static let repositoryRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()

  /// Xcode Cloud runs tests on a machine with the built products but no source
  /// checkout, so the catalog checks only run where the sources are (locally, fastlane).
  private static let sourcesAvailable = FileManager.default.fileExists(
    atPath: repositoryRoot.appending(path: catalogPaths[0]).path)

  private static let catalogPaths = [
    "TianganDizhi/AppWidgetShared/Localizable.xcstrings",
    "ShiChen/ShiChen.xcstrings",
  ]

  private static let spanishCatalogPaths = catalogPaths + ["TianganDizhi/InfoPlist.xcstrings"]

  /// The format specifiers of a string with positions dropped, sorted by
  /// position: `距離%1$@還有 %2$lld 分鐘` and `距離%@還有 %lld 分鐘` both give `[@, lld]`.
  private static func placeholders(in string: String) -> [String] {
    let regex = #/%(?:(\d+)\$)?(lld|ld|d|@|f|\.\d+f)/#
    return string.matches(of: regex)
      .enumerated()
      .map { index, match in (Int(match.1 ?? "") ?? index + 1, String(match.2)) }
      .sorted { $0.0 < $1.0 }
      .map(\.1)
  }

  private func entries(in path: String) throws -> [String: Entry] {
    let data = try Data(contentsOf: Self.repositoryRoot.appending(path: path))
    return try JSONDecoder().decode(Catalog.self, from: data).strings
  }
}
