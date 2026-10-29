# Analytics

Read this before adding, renaming or reporting an analytics event, or touching widget measurement.

## Setup
- Google Analytics via Firebase (`FirebaseAnalytics`, SPM, `upToNextMajor` from 12.18.0).
- **iOS only.** The `TianganDizhi` target also builds for macOS, but the Firebase app is
  registered for iOS. The SPM product carries `platformFilter = ios` so the Mac binary never
  links Firebase, and every body in `AnalyticsService` is `#if os(iOS)`.
- All call sites go through `AnalyticsService` (`TianganDizhi/Utilities/AnalyticsService.swift`);
  never `import FirebaseAnalytics` in view code. The file is also a member of the watch app
  target, where it compiles to a no-op (shared views reference it).
- Collection is **opt-out**, defaulting on, via `Constants.analyticsEnabled` in the shared
  app-group UserDefaults and a toggle in the 隱私 section of `SettingsView`. Toggling it off
  is deliberately not reported.
- In 12.x plain `FirebaseAnalytics` excludes IDFA; `FirebaseAnalyticsIdentitySupport` is the
  opt-in additive library. Do not add it without revisiting ATT and the privacy manifest.
- Event names live in `AnalyticsService.Event`: snake_case, under 40 chars, no
  `firebase_`/`google_`/`ga_` prefix. Raw values are reported dimensions: don't rename them.

## Widget measurement
WidgetKit exposes no impression callback, so "installed and kept" is the strongest available
proxy. All widget signal is gathered **in the app process**; the extensions stay Firebase-free.

| Event | Source | Answers |
|---|---|---|
| `widget_active` | daily inventory sweep | which widgets are installed, home vs lock |
| `widget_added` / `widget_removed` | snapshot diff | per-widget churn, the kill-or-fix signal |
| `widget_tapped` | `widgetURL` deep link | which widgets actually drive app opens |

- `WidgetInventoryReporter` runs on foreground, throttled to once per calendar day, and diffs
  against a snapshot in the shared app-group UserDefaults. On the **first** run it seeds the
  snapshot silently; otherwise every pre-existing widget reports as newly added.
- There is no `widget_config` event. The SiriKit `ConfigurationIntent`'s `date`/`location`
  parameters are not user-configurable and nothing reads them. Timeline providers leave them
  unset; don't write location into an intent.
- `WidgetCenter.currentConfigurations()` is iOS 18+; the reporter wraps the completion-handler
  form to stay on the iOS 17 minimum.
- Widget taps use `tiangandizhi://widget?kind=…&family=…`, built and parsed only through
  `WidgetDeepLink` so the two halves can't drift. `AppRouter.destination(forWidgetKind:)` maps
  kind to tab, and `knowledgeRoute(forWidgetKind:)` picks the 天干地支 screen to push (via
  `pendingKnowledgeRoute`, consumed by `KnowledgeView`) so the tap lands on the content the
  widget shows. The modifier is a no-op on watchOS, which has no analytics and where
  complications already launch the app.
- User properties (`widget_count`, `has_home_widget`, `has_lock_widget`, `top_widget_kind`)
  exist to segment every other metric by widget adoption.
- **Register `widget_kind`, `widget_family`, `widget_surface`, `setting_name` as custom
  dimensions in the GA4 console**, or they will not appear in any report.

## In-app events
| Event | Source | Answers |
|---|---|---|
| `screen_view` | the three `navigationDestination` sites | which content screens are read |
| `content_detail_opened` | routes carrying an entry | which 地支/卦 get looked up |
| `setting_changed` | every `SettingsView` toggle | which defaults users override |
| `onboarding_step_viewed` | onboarding `TabView` selection | where onboarding loses people |
| `share_invoked` | `ShareLink` tap | whether sharing is worth investing in |
| `custom_holiday_saved` / `custom_holiday_deleted` | 自訂節日 editor | whether users want their own days, lunar vs Gregorian |

- Content screens are instrumented **once** per tab, at `navigationDestination`, via the
  `AnalyticsScreen` conformances on `KnowledgeRoute`/`GuaRoute`/`ChartRoute`
  (`Navigation/NavigationModels.swift`), not in the individual view files. Add a route case
  and the compiler forces a `screenName`. `screenName` raw values are stable dimensions.
- Firebase's automatic screen tracking is off (`FirebaseAutomaticScreenReportingEnabled = NO`
  in `TianganDizhi/Info.plist`). Under SwiftUI it only logs mangled `UIHostingController`
  class names. Don't re-enable it.
- `settingChanged(_:_:reloadsWidgets:)` in `SettingsView` reports and reloads together. Pass
  `reloadsWidgets: false` for in-app-only settings so they don't show the "小組件已更新" toast.
- `share_invoked` counts *intent*: `ShareLink` has no completion callback.
