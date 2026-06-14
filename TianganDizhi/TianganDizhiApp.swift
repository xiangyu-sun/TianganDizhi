import ChineseAstrologyCalendar
import Combine
import os
import SwiftUI

private let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.App", category: "App")

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    FontManager.loadCustomFonts()
  }

  // MARK: Internal

  @StateObject private var fontProvider = FontProvider()

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
        .onOpenURL { url in
          handleDeepLink(url)
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
    guard url.scheme == "tiangandizhi" else { return }
    logger.info("Deep link received: \(url)")
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
