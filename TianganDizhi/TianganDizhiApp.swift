import ChineseAstrologyCalendar
import SwiftUI

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    #if os(iOS)
    UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: .weibeiBold, size: 34)!]
    UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: .weibeiBold, size: 12)!], for: [])
    #endif
  }

  // MARK: Internal

  @ObservedObject var updater = DateProvider()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(SettingsManager.shared)
    }

    #if os(macOS)
    let dizh = Date().shichen?.dizhi ?? .zi

    MenuBarExtra(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac + dizh.displayHourText) {
      VStack {
        Divider()
        Button("退出") {
          NSApplication.shared.terminate(nil)

        }.keyboardShortcut("q")
      }
    }

    #endif
  }
}
