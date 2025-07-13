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
    let dizh = updater.currentDate.shichen?.dizhi ?? .zi

    let god = updater.currentDate.twelveGod().map { "·" + $0.chinese } ?? ""
    
    MenuBarExtra(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac + dizh.displayHourText + god) {
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
