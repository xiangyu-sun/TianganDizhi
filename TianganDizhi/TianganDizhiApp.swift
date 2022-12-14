import ChineseAstrologyCalendar
import SwiftUI

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    #if os(iOS)
    UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: .weibeiBold, size: 34)!]
    UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: .weibeiBold, size: 12)!], for: [])
    #endif
  }

  // MARK: Internal

  @ObservedObject var updater = DateProvider()

  var body: some Scene {
    let dizh = try? GanzhiDateConverter.shichen(Date())
    WindowGroup {
      ContentView()
    }
    #if os(macOS)
    MenuBarExtra(updater.currentDate.chineseYearMonthDate + dizh!.displayHourText) {
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
