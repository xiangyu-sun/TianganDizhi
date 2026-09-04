import ChineseAstrologyCalendar
import Combine
import SwiftUI

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    FontManager.loadCustomFonts()
    AnalyticsService.configure()
  }

  // MARK: Internal

  @StateObject private var fontProvider = FontProvider()
  @StateObject private var router = AppRouter()

  @Environment(\.scenePhase) private var scenePhase

  #if os(macOS)
  // A TimelineView used as a MenuBarExtra `label:` collapses the WindowGroup
  // window to 0×0 (it never shows). Drive the menu bar title from a plain
  // @Published string instead so the label stays live AND the window appears.
  @StateObject private var menuBarTitle = MenuBarTitleProvider()
  #endif

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(fontProvider)
        .environmentObject(SettingsManager.shared)
        .environmentObject(router)
        .onOpenURL { url in
          handleDeepLink(url)
        }
        // Both entry points, because `.task` misses a warm relaunch and
        // `scenePhase` can already be `.active` on first appearance. The reporter
        // throttles itself to once a day, so running it twice costs nothing.
        .task {
          await WidgetInventoryReporter.reportIfNeeded()
        }
        .onChange(of: scenePhase) { phase in
          guard phase == .active else { return }
          Task { await WidgetInventoryReporter.reportIfNeeded() }
        }
    }

    #if os(macOS)
    MenuBarExtra(menuBarTitle.title) {
      MenuBarContentView()
    }
    #endif
  }

  // MARK: - Deep Link Handling

  private func handleDeepLink(_ url: URL) {
    guard url.scheme == WidgetDeepLink.scheme else { return }

    // A tap on a widget: attribute it, then land on the screen that widget is about.
    if let widget = WidgetDeepLink.parse(url) {
      let destination = AppRouter.destination(forWidgetKind: widget.kind)
      AnalyticsService.log(.widgetTapped(
        kind: widget.kind,
        family: widget.family,
        destination: destination.rawValue))
      router.selectedTab = destination
      return
    }

    AnalyticsService.log(.deepLinkOpened(host: url.host ?? "unknown"))
  }
}

#if os(macOS)
/// Supplies the macOS menu bar title, refreshed on each minute boundary.
/// Mirrors the main screen title (Chinese year/month/date + shichen + 十二神).
final class MenuBarTitleProvider: ObservableObject {

  // MARK: Lifecycle

  init() {
    refresh()
    scheduleNextTick()
  }

  deinit {
    timer?.invalidate()
  }

  // MARK: Internal

  @Published var title = ""

  // MARK: Private

  private var timer: Timer?

  private func refresh() {
    let date = Date()
    let dizhi = date.shichen?.dizhi ?? .zi
    let god = date.twelveGod().map { "·" + $0.chinese } ?? ""
    title = date.displayStringOfChineseYearMonthDateWithZodiac + dizhi.displayHourText + god
  }

  /// Fire at the start of the next minute, then every 60s thereafter.
  private func scheduleNextTick() {
    let now = Date()
    let secondsIntoMinute = Calendar.current.component(.second, from: now)
    let delay = TimeInterval(60 - secondsIntoMinute)
    let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
      self?.refresh()
      self?.startMinuteTimer()
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  private func startMinuteTimer() {
    let timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in
      self?.refresh()
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }
}
#endif
