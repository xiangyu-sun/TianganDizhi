# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TianganDizhi (天干地支) is a comprehensive Chinese astrology and calendar iOS/macOS/watchOS application that displays traditional Chinese calendar information, moon phases, weather data, and provides various widgets. The app supports multiple platforms and includes extensive localization.

## Build Commands

### Testing
```bash
# Run tests on iPhone 8 Plus and iPad Pro using fastlane
fastlane ios tests

# Run tests directly with xcodebuild
xcodebuild test -scheme TianganDizhi -destination 'platform=iOS Simulator,name=iPhone 8 Plus'
```

### Building
```bash
# Build for release using fastlane
fastlane ios release

# Build specific schemes
xcodebuild -scheme TianganDizhi build
xcodebuild -scheme ShiChenExtension build
xcodebuild -scheme "ShichenWatch Watch App" build
```

### Screenshots
```bash
# Capture app store screenshots
fastlane ios screenshots
```

## Git Workflow

### Release branch
`release` is the branch that drives the actual App Store build/deploy — changes on
`master` do not ship until they are also on `release`.

After changes land on `master`, sync them to `release`:
```bash
git merge-base --is-ancestor release master   # expect a clean fast-forward
git checkout release
git merge master                               # fast-forwards in the normal case
git push origin release
git checkout master                            # return to where you started
```
If `release` is *not* an ancestor of `master` (the `--is-ancestor` check fails), it
is not a clean fast-forward — surface that rather than forcing the merge.

### ChineseTranditionalCalendarUI package
The shared calendar UI lives in the `ChineseTranditionalCalendarUI` Swift package,
consumed here as a **remote** SwiftPM dependency (pinned by branch in
`Package.resolved`). When a fix is needed in that package:
- Edit it directly in its local clone at `/Users/xiangyu.sun/ChineseTranditionalCalendarUI`
  (the source of truth for shared calendar views) — do not duplicate the code app-side.
- Build/test the package there (`swift build`, `swift test`).
- The app cannot see the change until the package is committed + pushed to its
  `origin/master` and this repo's `Package.resolved` revision is bumped to the new
  SHA. `xcodebuild -resolvePackageDependencies` does **not** auto-advance a
  branch-tracked pin past its current commit — hand-edit the `revision` in
  `Package.resolved`, then re-resolve to validate.

## Architecture Overview

### Multi-Target Structure
The project consists of multiple targets for different platforms and widget extensions:

- **TianganDizhi** - Main iOS/macOS app
- **ShiChenExtension** - iOS widget extension
- **ShichenWatch Watch App** - watchOS app  
- **ShichenWatch** - watchOS widget extension
- **ShichenMacWidget** - macOS widget extension

### Core Dependencies
The app relies heavily on custom Swift packages for Chinese astrology calculations:
- `ChineseAstrologyCalendar` - Core calendar and date calculations
- `ChineseTranditionalMusicCore` - Traditional music theory
- `JingluoShuxueCore` - Traditional Chinese medicine concepts
- `Bagua` - I Ching hexagram calculations
- `Astral` - Astronomical calculations
- `ShangdianKit` - Commerce/subscription features

### Key Architecture Patterns

#### Date Management
- Views use `TimelineView(.everyMinute)` for live date updates — there is no `DateProvider` class
- Custom date extensions (`Date+Ganzhi.swift`, `Date+Jieqi.swift`) for Chinese calendar calculations
- `DayConverter` - Handles timezone conversions (GTM8 support)

#### Settings Management  
- `SettingsManager` - Centralized app settings (`ObservableObject`, injected via `environmentObject`)
- `FontProvider` - Reactive font management (`ObservableObject`, owns font selection logic, watches shared UserDefaults)
- Shared UserDefaults between app and extensions via app groups
- Constants defined in `Constants.swift` for consistent setting keys

#### Deployment Targets and API Constraints
- iOS 17.0 / macOS 14.0 minimum for the `TianganDizhi` app target (per
  `IPHONEOS_DEPLOYMENT_TARGET`/`MACOSX_DEPLOYMENT_TARGET` in the target's build
  settings — the project-level default of iOS 14/macOS 13 is stale and does not
  apply to this target). `@Observable`, the `Tab` API, and 0/2-param `onChange`
  are all available at this floor, but the codebase has not been migrated to
  them — it still uses `ObservableObject`/`@Published`/`@EnvironmentObject` and
  the older `onChange(of:perform:)` form throughout. Follow the existing
  pattern rather than introducing the newer APIs piecemeal.
- Custom `EnvironmentValues` keys use the `@Entry` macro (works on iOS 16+)

#### Analytics
- Google Analytics via Firebase (`FirebaseAnalytics`, SPM, pinned `from: 12.18.0`)
- **iOS only** — the `TianganDizhi` target also builds for macOS, but the Firebase app is
  registered for iOS. The SPM product carries `platformFilters = (ios)` so the Mac binary
  never links Firebase, and every body in `AnalyticsService` is `#if os(iOS)`.
- All call sites go through `AnalyticsService` (`Utilities/AnalyticsService.swift`) —
  never `import FirebaseAnalytics` in view code. The file is a member of both the app and
  the watch target, where it compiles to a no-op (shared views reference it).
- Collection is **opt-out**, defaulting on, via `Constants.analyticsEnabled` in the shared
  app-group UserDefaults and a toggle in the 隱私 section of `SettingsView`.
- In 12.x plain `FirebaseAnalytics` excludes IDFA; `FirebaseAnalyticsIdentitySupport` is
  the opt-in additive library. Do not add it without revisiting ATT and the privacy manifest.
- Event names live in `AnalyticsService.Event` — snake_case, under 40 chars, no
  `firebase_`/`google_`/`ga_` prefix. Raw values are reported dimensions: don't rename them.

#### Widget measurement
WidgetKit exposes no impression callback, so "installed and kept" is the strongest
available proxy. All widget signal is gathered **in the app process** — the extensions
stay Firebase-free.

| Event | Source | Answers |
|---|---|---|
| `widget_active` | daily inventory sweep | which widgets are installed, home vs lock |
| `widget_added` / `widget_removed` | snapshot diff | per-widget churn — the kill-or-fix signal |
| `widget_config` | `ConfigurationIntent` | whether `date`/`location` config is used |
| `widget_tapped` | `widgetURL` deep link | which widgets actually drive app opens |

- `WidgetInventoryReporter` runs on foreground, throttled to once per calendar day, and
  diffs against a snapshot in the shared app-group UserDefaults. On the **first** run it
  seeds the snapshot silently — otherwise every pre-existing widget reports as newly added.
- `widget_config` is emitted only for the SiriKit-intent widgets. The AppIntent ones
  (Calendar, Luck, JieqiHealth) return no readable configuration, and reporting them as
  "no custom values" would be indistinguishable from a genuine empty config.
- `WidgetCenter.currentConfigurations()` is iOS 18+; the reporter wraps the
  completion-handler form to stay on the iOS 17 minimum.
- Widget taps use `tiangandizhi://widget?kind=…&family=…`, built and parsed only through
  `WidgetDeepLink` so the two halves can't drift. `AppRouter.destination(forWidgetKind:)`
  maps kind → tab. The modifier is a no-op on watchOS, which has no analytics and where
  complications already launch the app.
- User properties (`widget_count`, `has_home_widget`, `has_lock_widget`, `top_widget_kind`)
  exist to segment every other metric by widget adoption.
- **Register `widget_kind`, `widget_family`, `widget_surface`, `setting_name` as custom
  dimensions in the GA4 console**, or they will not appear in any report.

#### In-app events
| Event | Source | Answers |
|---|---|---|
| `screen_view` | the three `navigationDestination` sites | which content screens are read |
| `content_detail_opened` | routes carrying an entry | which 地支/卦 get looked up — new widget ideas |
| `setting_changed` | every `SettingsView` toggle | which defaults users override |
| `onboarding_step_viewed` | onboarding `TabView` selection | where onboarding loses people |
| `share_invoked` | `ShareLink` tap | whether sharing is worth investing in |

- Content screens are instrumented **once** per tab, at `navigationDestination`, via the
  `AnalyticsScreen` conformances on `KnowledgeRoute`/`GuaRoute`/`ChartRoute` — not in the
  ~20 individual view files. Add a route case and the compiler forces a `screenName`.
- `screenName` raw values are stable dimensions; renaming one breaks report continuity.
- `settingChanged(_:_:reloadsWidgets:)` in `SettingsView` reports and reloads together.
  Pass `reloadsWidgets: false` for in-app-only settings so they don't show the
  "小組件已更新" toast for a change no widget reflects.
- `share_invoked` counts *intent* — `ShareLink` has no completion callback, so a tap is
  the most that can be observed.
- Toggling analytics off is deliberately not reported.

#### Widget Timeline Architecture
- `ShichenTimeLineSceduler` - Manages widget update timelines
- `MinuteTimeLineScheduler` - Handles minute-based updates
- Separate timeline providers for different widget types

#### UI Structure
The main app uses SwiftUI with a tab-based navigation:
- **MainView** - Primary时辰 (Shichen) display with circular clock
- **KnowledgeView** - Educational content about Chinese astrology
- **GuaListView** - I Ching hexagram information  
- **ChartListView** - Comprehensive charts and visualizations
- **SettingsView** - App configuration

### Platform-Specific Considerations

#### iOS/iPadOS
- Supports multiple size classes (compact/regular)
- Includes iOS widgets with various sizes
- Weather integration using WeatherKit

#### macOS
- Menu bar extra functionality showing current information
- Platform-specific UI adjustments using `#if os(macOS)`

#### watchOS  
- Dedicated watch app with simplified UI
- Watch-specific widget support
- Optimized for small screens

### Shared Code Organization
- `AppWidgetShared/` - Code shared between main app and widgets
- `Utilities/` - Common utility functions and extensions
- Asset catalogs organized by platform and feature

### Localization
- Supports Chinese (Simplified/Traditional) and English
- Uses `.xcstrings` files for modern localization
- Fastlane integration for App Store metadata in multiple languages

### Testing Structure
- Unit tests in `TianganDizhiTests/`
- UI tests in `TianganDizhiUITests/` 
- Timeline testing for widget functionality

## Development Notes

### Font Management
The app uses a custom font "WeibeiTC-Bold" with fallback to system fonts controlled by user preference.

### Weather Integration
Weather data is fetched using Apple's WeatherKit (iOS 16+) and integrated with location services for accurate sunrise/sunset times.

### Widget Development
When working on widgets, note that they share significant code with the main app through the `AppWidgetShared` folder. Timeline updates are coordinated between the app and widgets.

### Traditional Chinese Features
The app includes extensive traditional Chinese astrology features including:
- Tiangan (天干) and Dizhi (地支) stems and branches
- Jieqi (節氣) solar terms
- Moon phase calculations with Chinese names
- Twelve hour periods (Shichen 時辰)
- I Ching hexagrams and traditional symbolism