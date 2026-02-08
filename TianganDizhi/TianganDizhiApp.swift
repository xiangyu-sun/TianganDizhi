import ChineseAstrologyCalendar
import SwiftUI

@main
struct TianganDizhiApp: App {

  // MARK: Lifecycle

  init() {
    FontManager.loadCustomFonts()
    #if os(iOS)
    UINavigationBar.appearance().largeTitleTextAttributes = [.font: FontManager.safeUIFont(size: 34)]
    UITabBarItem.appearance().setTitleTextAttributes([.font: FontManager.safeUIFont(size: 12)], for: [])
    #endif
  }

  // MARK: Internal

  @StateObject private var fontProvider = FontProvider()
  @ObservedObject var updater = DateProvider()
  // @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(fontProvider)
        .environmentObject(SettingsManager.shared)
        .onOpenURL { url in
          handleDeepLink(url)
        }
    }
    // .onChange(of: scenePhase) { newPhase in
    //   #if os(iOS)
    //   if newPhase == .active {
    //     // Refresh Live Activity when app becomes active
    //     Task {
    //       await LiveActivityManager.shared.refreshActivity()
    //     }
    //   }
    //   #endif
    // }

    #if os(macOS)
    let dizh = updater.currentDate.shichen?.dizhi ?? .zi

    let god = updater.currentDate.twelveGod().map { "·" + $0.chinese } ?? ""
    
    MenuBarExtra(updater.currentDate.displayStringOfChineseYearMonthDateWithZodiac + dizh.displayHourText + god) {
      MenuBarContentView(updater: updater)
    }

    #endif
  }
  
  // MARK: - Deep Link Handling
  
  private func handleDeepLink(_ url: URL) {
    guard url.scheme == "tiangandizhi" else { return }
    
    // Handle different deep link paths
    // For now, just opening the app to main view is sufficient
    // Can be extended to navigate to specific tabs if needed
    print("Deep link received: \(url)")
  }
}
