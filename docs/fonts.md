# Fonts

Read this before touching fonts in the app, widgets or complications.

- The app font is Weibei (`WeibeiTC-Bold`), with fallback to system fonts controlled by user
  preference (`FontProvider`, `AppWidgetShared/FontProvider.swift`).
- Weibei is licensed to Apple, so it must **not** be bundled (ITMS-91198 / TN3214; uploads are
  rejected from Oct 1, 2027). It is a downloadable system font: `WeibeiFont.activate()`
  (`AppWidgetShared/Environment.swift`) downloads/registers it in the app. `Font.weiBei*` fall
  back to the bold system text style until it's active.
- **Home screen widgets use bundled LXGW WenKai TC** (`WidgetFonts/LXGWWenKaiTC-Medium.ttf`,
  SIL OFL 1.1, listed in `UIAppFonts` of the iOS (`ShiChen/Info.plist`) and Mac
  (`ShichenMacWidget/Info.plist`) widget extensions only).
- Why bundle at all: WidgetKit draws archived widget views in a system process that only sees
  fonts bundled in the extension, so a runtime-activated Weibei rendered blank (build 803).
- **Lock screen widgets and watch complications (`accessory*` families) never use a custom
  font.** Their views set system text styles (`.body`, `.headline`…) directly; don't read the
  `Font.weiBei*`/environment font values there.
- Any bundled font must pass Apple's font validator at `strict` (required for WidgetKit apps,
  TN3214).
