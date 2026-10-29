# Swift package dependencies

Read this before bumping a package, changing a pin, or fixing code that lives in one of the
author's own packages. All of them have local clones next to this repo in `~/Documents/GitHub/`.

## Pins (in `TianganDizhi.xcodeproj`)
- **By version** (`upToNextMajorVersion`): `ChineseAstrologyCalendar` (from 4.2.0), `Bagua`
  (from 1.1.0), `JingluoShuxueCore` (from 1.2.0, product `JingluoShuxue`), `firebase-ios-sdk`
  (from 12.18.0), `airbnb/swift` (from 1.0.0, the Airbnb Swift style/format plugin). Bump the
  minimum when the app needs a newer API; never switch the first three back to a branch, or
  SwiftPM can no longer resolve the graph (Bagua/Jingluo require ChineseAstrologyCalendar by
  version).
- **By branch**: `ChineseTranditionalCalendarUI` (`master`), `ChineseTranditionalMusicCore`
  (`main`), `AppStoreReviewPrompt` (`main`, iOS only). Their own `ChineseAstrologyCalendar`
  requirement must be a version range too.
- `Astral` (used by `ShiChen/Shared/Widget/RetangularWidgetView.swift`) arrives transitively;
  it is not a direct project dependency.

## Fixing something in ChineseTranditionalCalendarUI (or another branch-pinned package)
The shared calendar UI lives in `ChineseTranditionalCalendarUI`, consumed as a **remote**
dependency pinned by branch in
`TianganDizhi.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- Edit it in its local clone (`~/Documents/GitHub/ChineseTranditionalCalendarUI`), the source
  of truth for shared calendar views. Do not duplicate the code app-side.
- Build/test it there (`swift build`, `swift test`).
- The app cannot see the change until the package is committed and pushed to its
  `origin/master` and this repo's `Package.resolved` revision is bumped to the new SHA.
  `xcodebuild -resolvePackageDependencies` does **not** advance a branch-tracked pin past its
  current commit: hand-edit the `revision` in `Package.resolved`, then re-resolve to validate.
