//
//  Environment.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 22/10/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import CoreText
import JingluoShuxue
import os
import SwiftUI

extension String {
  /// The calligraphy font's family name: Weibei SC for Simplified Chinese,
  /// Weibei TC for every other language.
  static var weibeiBold: String { WeibeiFont.fontName }
}

// MARK: - WeibeiFont

/// Weibei TC is licensed to Apple, so it can't ship in the bundle (ITMS-91198,
/// TN3214). The OS offers it as a downloadable system font instead: `activate()`
/// downloads it once per device and registers it for this process.
///
/// Widgets can't use it. WidgetKit draws a widget's archived view in a system
/// process, which only sees fonts from the extension's own bundle (`UIAppFonts`),
/// not ones activated at runtime — text set in Weibei rendered blank. App
/// extensions report it unavailable; the home screen widget extensions (iOS, Mac)
/// bundle LXGW WenKai TC (SIL OFL 1.1, `WidgetFonts/`) instead.
///
/// Lock screen widgets and watch complications (the `accessory*` families) never
/// use a custom font — their views set system text styles directly.
enum WeibeiFont {
  /// Weibei SC (Simplified glyph forms) for Simplified Chinese, Weibei TC otherwise.
  /// Chosen from the language the UI is shown in, which is fixed for the life
  /// of the process.
  static let postScriptName = DisplayLanguage.app == .zhHans ? "WeibeiSC-Bold" : "WeibeiTC-Bold"
  /// The family name `Font.custom` takes for `postScriptName`.
  static let fontName = DisplayLanguage.app == .zhHans ? "Weibei SC Bold" : "Weibei TC Bold"
  /// The bundled calligraphy font home screen widgets use in Weibei's place.
  static let widgetFontName = "LXGWWenKaiTC-Medium"

  /// Whether this extension bundles `widgetFontName` (the watch extension doesn't).
  static let isWidgetFontBundled: Bool = {
    let font = CTFontCreateWithName(widgetFontName as CFString, 12, nil)
    return CTFontCopyPostScriptName(font) as String == widgetFontName
  }()

  /// Whether the font is registered in this process. CoreText substitutes a
  /// fallback for a name it can't find, so compare the name it resolved to.
  static var isAvailable: Bool {
    guard !isAppExtension else { return false }
    let font = CTFontCreateWithName(postScriptName as CFString, 12, nil)
    return CTFontCopyPostScriptName(font) as String == postScriptName
  }

  static let isAppExtension = Bundle.main.bundleURL.pathExtension == "appex"

  /// Downloads (if needed) and registers the font, returning whether it is now
  /// available. Gives up waiting after `timeout`; a download still in flight
  /// keeps going and is picked up by the next render.
  @discardableResult
  static func activate(timeout: TimeInterval = 10) async -> Bool {
    if isAvailable || isAppExtension { return isAvailable }
    let descriptor = CTFontDescriptorCreateWithNameAndSize(postScriptName as CFString, 0)
    return await withCheckedContinuation { continuation in
      // Resumed exactly once, by whichever of the two queues below gets there first.
      let resumed = OSAllocatedUnfairLock(initialState: false)
      let finish: @Sendable () -> Void = {
        let isFirst = resumed.withLock { done in
          defer { done = true }
          return !done
        }
        if isFirst { continuation.resume(returning: isAvailable) }
      }
      DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: finish)
      CTFontDescriptorMatchFontDescriptorsWithProgressHandler([descriptor] as CFArray, nil) { state, _ in
        if state == .didFinish { finish() }
        return true
      }
    }
  }
}

extension Font {
  /// Widgets use the bundled WenKai where there is one. Otherwise, until a
  /// calligraphy font is available, the bold system style — the same font the "use system font" setting picks.
  /// (`.custom` with a missing font falls back to a *regular*-weight system font
  /// at a fixed size.)
  ///
  /// Outside Chinese the calligraphy font only draws the Han glyphs: Weibei and
  /// WenKai have poor Latin, so Latin text uses the system font and the
  /// calligraphy font is its CoreText cascade (see ``CalligraphyFont``).
  private static func weiBei(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
    if !DisplayLanguage.app.isChinese {
      return CalligraphyFont.latinFriendly(size: size, relativeTo: style)
    }
    if WeibeiFont.isWidgetFontBundled {
      return .custom(WeibeiFont.widgetFontName, size: size, relativeTo: style)
    }
    return WeibeiFont.isAvailable ? .custom(.weibeiBold, size: size, relativeTo: style) : .system(style).bold()
  }

  static var weiBeiLargeTitle: Font { weiBei(size: 50, relativeTo: .largeTitle) }
  static var weiBeiTitle: Font { weiBei(size: 40, relativeTo: .title) }
  static var weiBeiTitle2: Font { weiBei(size: 30, relativeTo: .title2) }
  static var weiBeiTitle3: Font { weiBei(size: 24, relativeTo: .title3) }
  static var weiBeiBody: Font { weiBei(size: 22, relativeTo: .body) }
  static var weiBeiCallOut: Font { weiBei(size: 18, relativeTo: .callout) }
  static var weiBeiHeadline: Font { weiBei(size: 20, relativeTo: .headline) }
  static var weiBeiFootNote: Font { weiBei(size: 12, relativeTo: .footnote) }

  static var weiBeiTitleWatch: Font { weiBei(size: 28, relativeTo: .title) }
}

extension EnvironmentValues {
  #if os(watchOS)
  @Entry var titleFont: Font = .weiBeiTitleWatch
  #else
  @Entry var titleFont: Font = .weiBeiTitle
  #endif
  @Entry var largeTitleFont: Font = .weiBeiLargeTitle
  @Entry var title2Font: Font = .weiBeiTitle2
  @Entry var title3Font: Font = .weiBeiTitle3
  @Entry var bodyFont: Font = .weiBeiBody
  @Entry var calloutFont: Font = .weiBeiCallOut
  @Entry var headlineFont: Font = .weiBeiHeadline
  @Entry var footnote: Font = .weiBeiFootNote
  /// Whether layouts should use their larger, iPad-sized variants. Nothing
  /// reads a meaningful default — each root sets it: `ContentView` from its size
  /// class and width, and the widget views from `Bool.widgetShouldScaleFont`.
  @Entry var shouldScaleFont: Bool = false
  /// The language library names (節氣, festivals, 五行 …) are shown in; see
  /// `DisplayLanguage.app`.
  @Entry var displayLanguage: DisplayLanguage = .app
}

// MARK: - DisplayLanguage

extension DisplayLanguage {
  /// The language the UI is shown in. Follows the localization the bundle
  /// picked rather than `Locale.current`, so a device language the app has no
  /// strings for resolves to the same language as the strings on screen.
  static var app: DisplayLanguage {
    DisplayLanguage(identifier: Bundle.main.preferredLocalizations.first ?? "en")
  }

  /// The script for Chinese terms kept as glyphs in every locale (the 時辰
  /// dial, 干支, 卦): Simplified for Simplified Chinese, Traditional for
  /// everything else, since the library's canonical names are Traditional.
  var glyphLanguage: DisplayLanguage {
    self == .zhHans ? .zhHans : .zhHant
  }

  /// Whether this is Traditional or Simplified Chinese. Chinese keeps the app's
  /// Chinese-only wording (spelled-out numbers, 年/節/氣 suffixes, prose);
  /// every other language gets English names and format strings.
  var isChinese: Bool {
    self == .zhHant || self == .zhHans
  }

  /// The strings bundle for this language: the `<language>.lproj` of the main
  /// bundle when there is one, else the main bundle itself. Lets a function
  /// that takes an explicit `language:` read the catalog in that language
  /// instead of the device's — `String(localized: "…", bundle: language.localizationBundle)`.
  var localizationBundle: Bundle {
    guard let path = Bundle.main.path(forResource: identifier, ofType: "lproj"),
          let bundle = Bundle(path: path)
    else { return .main }
    return bundle
  }
}

// MARK: - CalligraphyFont

/// Fonts for non-Chinese languages: Latin in the system font, Han in the
/// calligraphy font (Weibei in the app, bundled LXGW WenKai TC in widgets),
/// through a CoreText cascade list on a system base font.
enum CalligraphyFont {
  /// The calligraphy font that is usable in this process, if any.
  static var cascadeFontName: String? {
    if WeibeiFont.isWidgetFontBundled { return WeibeiFont.widgetFontName }
    if WeibeiFont.isAvailable { return WeibeiFont.postScriptName }
    return nil
  }

  /// A bold system font at `size` whose cascade list starts with the
  /// calligraphy font. `nil` while no calligraphy font is available.
  static func cascadingFont(size: CGFloat) -> CTFont? {
    guard let cascadeFontName else { return nil }
    let base = CTFontCreateUIFontForLanguage(.emphasizedSystem, size, nil)
      ?? CTFontCreateWithName("Helvetica-Bold" as CFString, size, nil)
    let cascade = CTFontDescriptorCreateWithNameAndSize(cascadeFontName as CFString, size)
    let attributes: [CFString: Any] = [kCTFontCascadeListAttribute: [cascade]]
    let descriptor = CTFontDescriptorCreateCopyWithAttributes(CTFontCopyFontDescriptor(base), attributes as CFDictionary)
    return CTFontCreateWithFontDescriptor(descriptor, size, nil)
  }

  /// The SwiftUI font for a `Font.weiBei*` slot outside Chinese. The size is
  /// scaled for Dynamic Type when the font is made (iOS); until a calligraphy
  /// font is available it is the bold system style, as in Chinese.
  static func latinFriendly(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
    guard let font = cascadingFont(size: scaledSize(size, relativeTo: style)) else {
      return .system(style).bold()
    }
    return Font(font)
  }

  private static func scaledSize(_ size: CGFloat, relativeTo style: Font.TextStyle) -> CGFloat {
    #if os(iOS)
    let uiStyle: UIFont.TextStyle = switch style {
    case .largeTitle: .largeTitle
    case .title: .title1
    case .title2: .title2
    case .title3: .title3
    case .headline: .headline
    case .subheadline: .subheadline
    case .callout: .callout
    case .footnote: .footnote
    case .caption: .caption1
    case .caption2: .caption2
    default: .body
    }
    return UIFontMetrics(forTextStyle: uiStyle).scaledValue(for: size)
    #else
    return size
    #endif
  }
}

// MARK: - GlossedText

/// A Chinese term with an English gloss under it (group C: lists and reference
/// rows). In Chinese it is just the glyph text, so Chinese layouts stay as
/// they are; in other languages the gloss follows in a smaller secondary line.
///
/// The combined accessibility label reads glyph and gloss together:
/// "子, Zi, Rat".
struct GlossedText: View {
  @Environment(\.displayLanguage) private var displayLanguage

  let glyph: String
  /// The gloss shown outside Chinese, e.g. "Zi · Rat". Empty for none.
  let gloss: String
  var alignment: HorizontalAlignment = .leading

  var body: some View {
    if displayLanguage.isChinese || gloss.isEmpty {
      Text(glyph)
    } else {
      VStack(alignment: alignment, spacing: 0) {
        Text(glyph)
        Text(gloss)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
          .minimumScaleFactor(0.8)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(Self.accessibilityText(glyph: glyph, gloss: gloss))
    }
  }

  /// "子, Zi, Rat" — the glyph, then the gloss with its separators read as commas.
  static func accessibilityText(glyph: String, gloss: String) -> String {
    guard !gloss.isEmpty else { return glyph }
    return glyph + ", " + gloss.replacingOccurrences(of: " · ", with: ", ")
  }
}

/// The one-line note above library prose that only exists in Chinese (group D:
/// health tips, 宜/忌, meanings, aliases) when the app is not in Chinese.
struct ChineseOnlyCaption: View {
  var body: some View {
    Text("以下內容僅提供中文")
      .font(.footnote)
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal)
      .padding(.vertical, 4)
  }
}

extension DisplayLanguage {
  /// Joins the non-empty parts of a gloss with " · ".
  static func gloss(_ parts: String...) -> String {
    parts.filter { !$0.isEmpty }.joined(separator: " · ")
  }
}

// MARK: - Term glosses

/// The English line under a glyph (group C): the term's name, plus a second
/// fact where one reads well ("Zǐ · Rat"). Each returns "" in Chinese, where
/// the glyph stands alone.
extension Tiangan {
  func gloss(in language: DisplayLanguage) -> String {
    language.isChinese ? "" : DisplayLanguage.gloss(localizedName(in: language), wuxing.localizedName(in: language))
  }
}

extension Dizhi {
  func gloss(in language: DisplayLanguage) -> String {
    language.isChinese ? "" : DisplayLanguage.gloss(localizedName(in: language), Zodiac(self).localizedName(in: language))
  }
}

extension Wuxing {
  /// The element as sentence text: the glyph in Chinese, the English name
  /// ("Wood") otherwise.
  func sentenceText(in language: DisplayLanguage) -> String {
    language.isChinese ? chineseCharacter : localizedName(in: language)
  }

  /// "Wood" under 木.
  func gloss(in language: DisplayLanguage) -> String {
    language.isChinese ? "" : localizedName(in: language)
  }
}

extension Ganzhi {
  /// "Jiǎzǐ · Gold in the Sea" under 甲子.
  func gloss(in language: DisplayLanguage) -> String {
    language.isChinese ? "" : DisplayLanguage.gloss(localizedName(in: language), nayin.localizedName(in: language))
  }
}

// MARK: - Script conversion

extension String {
  /// This (Traditional Chinese) library string in the script `language` uses:
  /// Simplified for `.zhHans`, unchanged for everything else.
  ///
  /// Only for library strings that have no `localizedName(in:)` of their own
  /// (aliasName, colorDescription, 情緒, almanac prose …). The ICU transform is
  /// wrong for some single characters (乾 becomes 干), so trigram, hexagram and
  /// other names that have an API must use it instead.
  func converted(to language: DisplayLanguage) -> String {
    guard language == .zhHans else { return self }
    return applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? self
  }
}

extension LunarMansion {
  /// The mansion's single character without the 宿 suffix (角, 虛 or 虚), the
  /// form the app shows next to "星宿:". `localizedName(in:)` includes the suffix.
  func glyph(in language: DisplayLanguage) -> String {
    let name = localizedName(in: language.glyphLanguage)
    return name.hasSuffix("宿") ? String(name.dropLast()) : name
  }
}

extension Shichen {
  /// The current 刻 as a label: "初刻"-style spelled-out ordinal in Chinese,
  /// "Quarter 3" outside Chinese, where the ordinal is an `Int` so the catalog
  /// can phrase it.
  func keText(language: DisplayLanguage) -> String {
    let bundle = language.localizationBundle
    if language.isChinese {
      return String(localized: "\(currentKeSpellOut)刻", bundle: bundle)
    }
    return String(localized: "\(currentKe + 1)刻", bundle: bundle, comment: "The current ke (quarter of a double hour) outside Chinese; %lld is its number, 1 to 8")
  }
}

extension LunarMansion {
  /// The mansion as the "星宿:" line shows it: the single character in Chinese
  /// (角, 虛 or 虚), the English name ("Horn") otherwise.
  func shortName(in language: DisplayLanguage) -> String {
    language.isChinese ? glyph(in: language) : localizedName(in: language)
  }
}

extension 十二经脉 {
  /// The organ's short name for the hour strip and clock centre: 膽 in
  /// Chinese, "Gallbladder" in English (the meridian's name without "Meridian").
  func organText(in language: DisplayLanguage) -> String {
    if language.isChinese { return organReference.converted(to: language) }
    return localizedName(in: language).replacingOccurrences(of: " Meridian", with: "")
  }
}

extension Date {
  /// The lunar date for tight spots (lock screen, menu bar, widgets): the full
  /// year, zodiac, month and day in Chinese; in English the month and day with
  /// the zodiac year ("5th Month 9th, Year of the Tiger" would not fit), so it
  /// drops the stem-branch year name.
  func compactLunarDate(language: DisplayLanguage) -> String {
    if language.isChinese { return lunarDateWithZodiac(language: language) }
    guard let lunar = lunarDate() else { return "" }
    return "\(lunar.formatted(.monthDay, in: language)) · \(lunar.zodiac.localizedName(in: language))"
  }
}

extension View {
  /// Lets text that is longer in English wrap and shrink where the Chinese fits
  /// on one line. Chinese layouts are untouched.
  @ViewBuilder
  func englishFit(_ language: DisplayLanguage, lines: Int = 2, minimumScale: CGFloat = 0.6) -> some View {
    if language.isChinese {
      self
    } else {
      lineLimit(lines).minimumScaleFactor(minimumScale).multilineTextAlignment(.center)
    }
  }
}

extension Bool {
  /// Widgets have no useful size class, so they scale up on iPad — the same
  /// devices the old `UIScreen.main.bounds.width > 744` default picked out.
  static var widgetShouldScaleFont: Bool {
    #if os(iOS)
    UIDevice.current.userInterfaceIdiom == .pad
    #else
    false
    #endif
  }
}
