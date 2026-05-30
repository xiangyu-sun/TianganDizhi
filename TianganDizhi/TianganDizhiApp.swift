import ChineseAstrologyCalendar
import SwiftUI

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    FontManager.loadCustomFonts()
  }

  // MARK: Internal

  @StateObject private var fontProvider = FontProvider()

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
    MenuBarExtra {
      MenuBarContentView()
    } label: {
      TimelineView(.everyMinute) { context in
        let date = context.date
        let dizh = date.shichen?.dizhi ?? .zi
        let god = date.twelveGod().map { "·" + $0.chinese } ?? ""
        Text(date.displayStringOfChineseYearMonthDateWithZodiac + dizh.displayHourText + god)
      }
    }
    #endif
  }

  // MARK: - Deep Link Handling

  private func handleDeepLink(_ url: URL) {
    guard url.scheme == "tiangandizhi" else { return }
    print("Deep link received: \(url)")
  }
}
