# Localization roadmap (draft for review, 2026-11-01)

## Where we are today

**The App Store says the app speaks 12 languages, but the app itself speaks only Traditional Chinese.**

| Area | State |
|---|---|
| App UI (`TianganDizhi/`) | **No `Localizable.xcstrings`.** ~284 unique hard-coded Traditional Chinese literals across ~40 files (heaviest: `SettingsView` 35, `WuxingRelationshipView` 27, `BaziView` 25, `MainView` 23, `SpecialDayCatalog` 19, `CustomHolidaysView` 18). |
| iOS widgets (`ShiChen/ShiChen.xcstrings`) | 2 keys (Live Activity strings). Widget names/descriptions in `WidgetConstants.swift` are plain `String`s, so they aren't extracted. |
| Watch widgets (`ShichenWatch/Localizable.xcstrings`) | 31 keys, 7 translated, mixed 冲/沖 forms. |
| `InfoPlist.xcstrings` | en / zh-Hans / zh-Hant done (the English location prompt has a typo: "yoru"). |
| Project | `developmentRegion = en`, `knownRegions` = en, zh-Hans, zh-Hant. |
| Library calls | The app never calls the `DisplayLanguage` / `localizedName(in:)` API. It shows `chineseCharacter`, `chineseName`, `traditionalChineseName`, `rawValue` directly. |
| App Store metadata | 12 locales (en-US, zh-Hans, zh-Hant, ja, ko, ru, es-ES, fr-FR, th, vi, id, ms). Screenshots only for zh-Hans and zh-Hant. |

What this means for users:
- **zh-Hans users** (an advertised locale with its own screenshots) get Traditional Chinese.
- **English users** read an English App Store description, then open an app that is all Chinese.
- The other 9 locales have the same mismatch.

## Dependencies: what's ready, what isn't

| Package (pinned) | Ready | Gap |
|---|---|---|
| `ChineseAstrologyCalendar` 4.2.0 (latest tag, already pinned) | ✅ `DisplayLanguage` (`zhHant`, `zhHans`, `en`, `ru`, `es`; a struct, so more can be added in minor releases). `localizedName(in:)` on Tiangan, Dizhi (+ `localizedHourName`), Ganzhi, Nayin, Wuxing, Zodiac, Jieqi, ChineseFestival, TwelveGods, LunarMansion, FourSymbol, FangWei, Season, MoonPhase, LunarMonth, DizhiRelationship, Day, Shichen ke. `LunarDate.formatted(_:in:)`, `ChineseAlmanac`/`AlmanacText`, `Localized{Jieqi,Festival}ContentProvider`. ru/es exist only for festivals and 節氣; other types fall back to English. | (a) **Prose is zh-Hant only on purpose**: `Jieqi.healthTip`, `seasonalFoods`, `TwelveGods.meaning/do/dontDo`, `ChineseFestival.meaning`. (b) **Chinese-only helpers the app relies on**: `Dizhi.aliasName`, `organReference`, `displayHourText`, `chineseName`. A `localizedAliasName(in:)` would be a small minor-release addition. (c) **No `ja`/`ko`/`vi`/`fr`** (needed for Phase 3). (d) The local clone is 1 commit ahead of origin (docs only). Not a blocker. |
| `Bagua` 1.1.0 | ✅ Trigram name/象 and all 64 hexagrams in zh-Hant, zh-Hans and en (Wilhelm–Baynes titles), plus pinyin. | None for zh/en. |
| `JingluoShuxueCore` 1.2.0 | ✅ 十二經脈, 奇經八脈, 五臟, 六腑 in zh-Hant, zh-Hans and en. | 主要功能, 主治病症 and `情緒` stay zh-Hant on purpose. The 五行 screen shows `wuzang.情緒`. |
| `ChineseTranditionalCalendarUI` (master `7f612d9`) | ❌ | **This is the blocker.** It hard-codes `.zhHant` (`CalendarDate.swift:53`, `chineseYearMonthDate`) and has ~30 Chinese literals in `FourPillarsView`, `TwelveGodsView`, `DayDetailView`, `LunarMansionView`, `MoonPhaseView`, `SolarTermBadge`, `JieqiDetailView`. It has no `defaultLocalization` and no resources. It needs `defaultLocalization: "en"`, a `Localizable.xcstrings` read with `bundle: .module`, and a `displayLanguage` environment value or parameter. It blocks zh-Hans and en on the calendar screens. |
| `ChineseTranditionalMusicCore` (main `ca7f3c3`) | ❌ | ~30 Chinese literals (律呂, 五音 names). These are terms, so add `LocalizedNaming` with zh-Hans and pinyin/English. Small job, low priority (used only by the 地支/律呂 and 五音 screens). |
| `AppStoreReviewPrompt` | Probably nothing to do (it calls the system review prompt). | Not verified: there's no local clone. |

**Bottom line:** the data layer is ready for zh-Hans and en. The two UI/terminology packages are not, and `ChineseTranditionalCalendarUI` is the one that blocks a phase.

## What to translate, and what not to

The product *is* the Chinese terminology and calligraphy, so "translate everything" would remove its point. Every string gets one of four treatments:

### A. Keep in Chinese in every locale (but switch to Simplified script for zh-Hans)
- The glyph displays: the 時辰 dial (子丑寅…), 天干/地支 characters, 干支 pairs (甲子), the 八字 pillars, trigram/hexagram symbols, the big Weibei headings on the main screen. **Why:** this is the identity of the app, and the arc/rotated layouts (`YangliShierPiguaView`, `TianganStem`, menu-bar dial) only work for single glyphs.
- Classical text: 十二時辰頌 (`ShiciView`) and other quoted verse. A bad poetry translation is worse than none; an optional prose gloss can come later.
- Home-screen name `天干地支` (`CFBundleDisplayName`). It's the brand, and it's already the same in all three catalogs.
- 唐譜 notation symbols and 律呂 names (add pinyin as a secondary line).

### B. Translate fully
- App chrome: tab titles (`ContentView`), section/navigation titles, all of Settings (titles, subtitles, footers), onboarding, buttons (取消/儲存/刪除/開始使用), empty states, errors and retry prompts, the location-off banner, menu-bar menu items, share/copy text, "小組件已更新" toast.
- Widget gallery text: `configurationDisplayName`/`description` (`WidgetConstants`, `LuckWidget`, `CalendarWidget`, `JieqiHealthWidget`, `ChineseFestivalWidget`, `HourlyWidget`), App Intent parameter titles (Configuration, Date, Location), Live Activity text.
- The 自訂節日 editor (form labels, placeholders, the short-month footnote).
- Accessibility labels. These are full sentences assembled from Chinese fragments today, so they need format strings.
- Countdown and duration text ("\(days)日後", "距離…還有 \(mins) 分鐘", "第…刻"): plural variants and positional arguments, not concatenation.
- Gregorian dates, times and weather units are already formatted by `formatted()`; just stop wrapping them in Chinese sentence fragments.

### C. Chinese glyph + localized gloss (for non-Chinese locales)
Show the Chinese as the primary line, with `localizedName(in:)` (plus pinyin where the library has it) as a secondary line. Example: **子** · Zi · Rat · 23:00–01:00.
- 節氣 (立春 · Start of Spring), festivals, zodiac animals, 五行 (Wood/Fire…), 十二建除神, 二十八宿 and 四象, moon phases, 方位, 納音, trigram/hexagram names (Bagua), meridians and organs (Jingluo), lunar month/day (`LunarDate.formatted(_:in:)`).
- Knowledge section headings ("Five Phases: generating & overcoming · 五行生克").
- 八字 labels (年柱/月柱/日柱/時柱, 日主, 用神, 大運): translate the label, keep the term as a gloss.

### D. Leave untranslated for now (show Chinese with a one-line localized caption)
- 節氣養生 tips and seasonal foods: the `JieqiHealthWidget` and the solar-term detail. They're health-adjacent, so machine translation is risky; the library deliberately ships zh only.
- 宜/忌 lists and Twelve Gods meanings, festival meanings, `aliasName`/`organReference` prose, 情緒.
- Revisit with human translation only if analytics show real non-Chinese usage of those screens.

## Phased plan

### Phase 0 — Groundwork (no visible change) · ✅ done 2026-11-01
What landed:
- The watch's `Localizable.xcstrings` moved to `TianganDizhi/AppWidgetShared/` and is now in all 5 product targets. It holds 280 keys, every translatable one with an explicit zh-Hant value. The placeholder-only keys and 十二時辰頌 are marked do-not-translate.
- String-typed UI text goes through `String(localized:)` or `LocalizedStringKey`.
- `\.displayLanguage` environment value, plus `DisplayLanguage.app` and `.glyphLanguage`. Nothing reads them yet; Phase 1 adopts them.
- `LocalizationCatalogTests`: zh-Hant coverage, matching placeholders, the zh-Hant table shipping in the app bundle, and the `glyphLanguage` policy.
- UI tests run in Traditional Chinese unless the run is already in Chinese.
- Rules added to CLAUDE.md.

Deliberate deviations from the plan below:
- **No plural variants yet.** Counts are passed as `Int` (`%lld`), so plural variants can be added when English is translated. 節氣 and festival countdowns still pass the spelled-out Chinese number (十五日後), so Phase 2 has to restructure them for English.
- **The 12 lunar month names in `SpecialDayCatalog`** (正月…臘月) stay as literals. They're terms, so Phase 1 switches them to `LunarMonth.localizedName(in:)`.
- **The watch's `%@ %@` override (no space in Chinese) was dropped**, because it would have changed the iOS countdown widget. The watch's countdown and inline complications now keep the space, the same as iOS.
- **The 自訂節日 footer still formats its date with a fixed zh-Hant locale.** Phase 2 changes that.

Original plan:
1. Add one `Localizable.xcstrings` for the app, and make it a member of every target that compiles `AppWidgetShared/` (the same way `ShiChen.xcstrings` already belongs to 5 targets). Fold the watch catalog into it. Build once so Xcode extracts the `Text("…")` literals.
2. **Keep `developmentRegion = en` and keep the Chinese literals as keys** (recommended). Unsupported languages then fall back to English once English is done, and no call site has to change. The zh-Hant value is the key itself. The alternative (making zh-Hant the source language) makes German, Thai, etc. fall back to Chinese.
3. Make the strings the extractor misses localizable: `String`-typed constants and computed properties (`WidgetConstants`, `SpecialDayCatalog` month names and 農曆/公曆 labels, `Date+Jieqi` text, `Date+ShichenProgress`, `MeasurmentFormatterManager`) move to `String(localized:)` / `LocalizedStringResource`. Library-provided strings stay `Text(verbatim:)`, or plain `String` values, so they don't end up in the catalog.
4. Replace interpolated Chinese sentences with format keys (positional `%1$@`) and plural variants.
5. Add `@Entry var displayLanguage: DisplayLanguage`, resolved with `DisplayLanguage(locale:)` in the app, widgets, watch and menu bar. Add one app-side policy, `termLanguage`: zh-Hans → `.zhHans`, every other locale → `.zhHant` for the glyph line in group A/C, plus the device language for the gloss line.
6. Pin the UI tests to zh-Hant (`-AppleLanguages (zh-Hant)` in the test plan) so they keep passing. Add a pseudo-language/double-length run to the scheme for layout checks.
7. Add a small unit test that fails when a shipping language has `new`/`needs_review` entries in the catalog.
8. Add a rule to CLAUDE.md: new UI strings go through the catalog, and term names come from `localizedName(in: displayLanguage)`.

### Phase 1 — Simplified Chinese · ~M (cheapest, fixes an advertised locale)
1. Convert every key with OpenCC (`t2s` + phrase table) to fill zh-Hans, then review by hand. Watch for 後→后, 曆→历, 臟→脏, 沖→冲, 衝 vs 沖, 鐘 vs 鍾, 乾 (the trigram stays 乾).
2. Swap direct `chineseCharacter`/`chineseName`/`traditionalChineseName` display calls to `localizedName(in: termLanguage)`.
3. Fonts: use Weibei **SC** for zh-Hans (also a downloadable Apple font; extend `WeibeiFont.activate()`). Widgets: the bundled LXGW WenKai TC covers all Simplified characters I tested but draws them with TC glyph forms. **Decision:** accept that, or also bundle LXGW WenKai (SC), which costs bundle size.
4. **Dependency:** `ChineseTranditionalCalendarUI` takes a `displayLanguage` and gets its own catalog (zh-Hant/zh-Hans first). Ship it the usual way: push to master, then hand-bump the `Package.resolved` revision.
5. Re-shoot the zh-Hans screenshots, which currently show Traditional UI.

### Phase 2 — English · ~L
1. Translate groups B and C from a glossary file (`docs/glossary.md`: term → English → pinyin, a single source of truth, matched to the library's English names).
2. Fonts: Weibei/WenKai for the hanzi glyph lines, the system font for Latin chrome in non-Chinese locales (decide in `FontProvider` by locale, not only by the `useSystemFont` toggle).
3. Layout pass: small and accessory widget families, menu bar, Dynamic Type, iPad/Mac small windows (reuse the resizability probe). English runs roughly 1.5–2× longer than Chinese.
4. Group D screens get a short English caption ("Traditional seasonal-health notes, in Chinese").
5. `ChineseTranditionalCalendarUI` and `ChineseTranditionalMusicCore` get English.
6. en-US screenshots with the English UI; check the en-US description against what actually ships.

### Phase 3 — next languages, chosen by data · per language ~M
- Before picking: check GA4's automatically collected **language** and **country** dimensions in Firebase (no new events needed).
- **Japanese**: the strongest candidate. Japan uses 干支, 節気 and 八卦 natively in kanji, so groups A/C can stay as kanji. It needs the library to add `DisplayLanguage.ja`, because Japanese names differ in places (啓蟄 vs 驚蟄, 処暑, festival names). Chrome is ~300 strings.
- **Korean**: the library needs `.ko` (입춘, 갑자). The widget font **has no Hangul**, so Korean text in widgets needs the system font.
- **ru / es**: the library already has festival and 節氣 text, so these are the cheapest after en.
- **fr, vi, th, id, ms**: no library support. Thai also lacks a widget font glyph set.

### Do this now, whatever else you decide
Until a locale has a localized UI, its App Store metadata should say which languages the app is in (for example, "Interface in Chinese; English coming soon"). That avoids "nothing is in my language" reviews. Fix the "yoru" typo in `InfoPlist.xcstrings` at the same time.

## Decisions I need from you
1. Keep `en` as the development region with Chinese keys (recommended), or switch the source language to zh-Hant?
2. Keep `天干地支` as the home-screen name in every locale (recommended)?
3. Group D prose for non-Chinese users: show Chinese with a caption (recommended), hide it, or commission human translation?
4. Simplified widget font: keep WenKai TC (no extra size) or bundle WenKai SC?
5. Which Phase 3 languages, if any, and whether to look at the GA4 language data first (recommended)?
6. The order of the dependency work: `ChineseTranditionalCalendarUI` at the start of Phase 1 (recommended), with `ChineseTranditionalMusicCore` deferred to Phase 2.
