# CLAUDE.md

TianganDizhi (天干地支) is a SwiftUI Chinese calendar/astrology app for iOS, macOS (incl. a menu
bar extra) and watchOS: 時辰 clock, 節氣/festivals, moon phase, WeatherKit sun times, 天干地支
knowledge, I Ching, charts, and many widgets. The UI is Traditional and Simplified Chinese; English
is in progress (`docs/localization-roadmap.md`). App Store metadata lives in `fastlane/metadata`.

## Build and test
```bash
xcodebuild -scheme TianganDizhi -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild test -scheme TianganDizhi -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:TianganDizhiTests          # drop -only-testing to also run the UI tests
xcodebuild -scheme TianganDizhi -destination 'generic/platform=macOS' build
xcodebuild -scheme "ShichenWatch Watch App" -destination 'generic/platform=watchOS Simulator' build
```
- Needs the Metal Toolchain (`Utilities/TextureShaders.metal`); if the build says it's missing,
  ask the user to run `xcodebuild -downloadComponent MetalToolchain`.
- `name=` matches only the newest iOS runtime; check `xcodebuild -showdestinations` if it fails.
- The `TianganDizhi` scheme uses `TianganDizhi.xctestplan` (`TianganDizhiTests` + `TianganDizhiUITests`).
- Other shared schemes: `ShiChenExtension`, `ShichenWatchExtension`, `ShichenWatch Watch App (Notification)`.
- fastlane (`fastlane/Fastfile`): `ios release`, `mac release`, `ios screenshots`, `ios metadata`,
  `mac metadata`, `all_metadata`. `fastlane ios tests` runs the full suite on the newest available
  iPhone and iPad simulators; run it outside the sandbox with a UTF-8 locale (`LANG=en_US.UTF-8`).

## Targets and folders
| Target | Folder | What |
|---|---|---|
| `TianganDizhi` | `TianganDizhi/` | iOS + macOS app (iOS 17 / macOS 14 minimum) |
| `ShiChenExtension` | `ShiChen/` | iOS widgets (iOS only) |
| `ShichenMacWidgetExtension` | `ShichenMacWidget/` | macOS widgets |
| `ShichenWatch Watch App` | `ShiChenWatch Watch App/` + `TianganDizhi/Watch/` | watchOS app (watchOS 10) |
| `ShichenWatchExtension` | `ShichenWatch/` | watch complications/widgets |
| `TianganDizhiTests` / `TianganDizhiUITests` | same names | tests (XCTest + Swift Testing) |

Inside `TianganDizhi/`: `Tabs/` (`MainView` 時辰, `Knowledge/`, `Gua/`, `Chart/`, `SettingsView`),
`Navigation/` (`AppRouter`, `AppTab`, route enums), `AppWidgetShared/` (code compiled into app
and widgets: `Constants`, `FontProvider`, `SpecialDayCatalog`, `WidgetDeepLink`,
`Timeline/` schedulers), `Utilities/` (`AnalyticsService`, `WidgetInventoryReporter`, ...),
`Date+Jieqi.swift`. Widget timeline providers are in `ShiChen/Shared/IntentTimelineProvider/`.

Core logic comes from the author's packages `ChineseAstrologyCalendar`, `Bagua`,
`JingluoShuxueCore`, `ChineseTranditionalCalendarUI`, `ChineseTranditionalMusicCore`.

## Code rules and gotchas
- **Solar terms and festivals follow the `useGTM8` setting** (節日與節氣使用東八區時間). Use the
  `Date+Jieqi.swift` helpers (`jieqiDayAligned`, `isJieqiDayAligned`, `nextJieqiDayAligned`,
  `displayedJieqi`, `jieQiDisplayText`), which pass `TimeZone.solarTerm` to the library's
  `jieqi(in:)` family. Never call the library's plain `jieqi`/`isJieqiDay`/`nextJieqi` in UI
  code (fixed to China time). Today's festival: `chineseFestival(timeZone: .solarTerm)`.
  Exception: `DaYunCalculator`/Bazi are pinned to China time on purpose.
- **Special days** (festivals, 節氣, 自訂節日) come from `SpecialDayCatalog.sources()`, shared by
  the 節日曆 screen, the festival widget and `MainView`. Use `currentOrNextSpecialDay` for
  "today / next"; the library's `nextSpecialDay` only looks after the date.
- 自訂節日 are `[CustomHoliday]` JSON under `Constants.customHolidays`, edited in
  `CustomHolidaysView` (which reloads the `SpecialDay` widget). The watch has its own app
  group, so they don't sync there.
- Lunar strings: `lunarDateWithZodiac` / `lunarDateWithZodiacGTM8` / `lunarDayText`; the
  library's `displayStringOf…` properties are deprecated.
- Settings are `@AppStorage(..., store: Constants.sharedUserDefault)` (app group
  `group.uriphium.tiangandizhi`), keys in `Constants.swift`, read where needed. No central
  settings object. Live time uses `TimelineView(.everyMinute)`.
- State uses `ObservableObject`/`@Published`/`@EnvironmentObject`; don't introduce
  `@Observable` or the `Tab` API piecemeal. `onChange` uses the two-parameter form only.
  Custom `EnvironmentValues` keys use `@Entry`.
- In `SettingsView`, report + reload via `settingChanged(_:_:reloadsWidgets:)`; pass
  `reloadsWidgets: false` for in-app-only settings.
- **Analytics**: only through `AnalyticsService` (iOS only, no-op elsewhere); extensions stay
  Firebase-free; never rename event or `screenName` raw values. Details: `docs/analytics.md`.
- **Fonts**: never bundle Weibei (activated at runtime via `WeibeiFont.activate()`); home
  screen widgets use bundled LXGW WenKai TC; `accessory*` widgets/complications use system
  text styles only. Details: `docs/fonts.md`.
- **Strings**: one catalog, `AppWidgetShared/Localizable.xcstrings`, in all 5 product targets.
  Keys are the Traditional Chinese literals (development language stays `en`), and every key
  needs an explicit zh-Hant value (`LocalizationCatalogTests`); a missing one would fall back to
  English. UI text goes through `Text("…")`/`LocalizedStringKey` or `String(localized:)`, never
  a plain `String` or `+` concatenation; pass numbers as `Int` so they can take plural variants.
  Refresh the catalog with `xcodebuild -exportLocalizations -project TianganDizhi.xcodeproj
  -localizationPath <tmp> -exportLanguage zh-Hant`, then give new keys a zh-Hant value. Library
  names (節氣, festivals, 五行 …) come from `localizedName(in:)` with `\.displayLanguage`
  (`.glyphLanguage` for terms kept as Chinese glyphs). Never translate 十二時辰頌 or the dial glyphs.
- Use `#if os(macOS)` / `#if os(iOS)` for platform splits; shared files compile into several
  targets, so check target membership when adding files.

## Git and release
- Work on `master`. `release` drives the App Store build; nothing ships until it's there.
  Sync after changes land on `master`:
  `git merge-base --is-ancestor release master && git checkout release && git merge master && git push origin release && git checkout master`.
  If the ancestor check fails it isn't a fast-forward: surface it, don't force.

## Deeper docs (read when relevant)
- `docs/dependencies.md`: package pins and how to ship a fix in `ChineseTranditionalCalendarUI`.
- `docs/analytics.md`: Firebase setup, widget measurement, event catalogue.
- `docs/fonts.md`: Weibei licensing, widget font rules and why.
- `docs/localization-roadmap.md`: what gets translated, phases, dependency gaps.
- `CHANGELOG.md`: user-visible changes; `PLAN_TEST_COVERAGE.md`: test-coverage plan.
- `fastlane/README.md`: lanes and metadata/screenshot tooling.
