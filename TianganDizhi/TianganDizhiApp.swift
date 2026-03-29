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
  @StateObject private var dateProvider = DateProvider()
  // @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(fontProvider)
        .environmentObject(SettingsManager.shared)
        .environmentObject(dateProvider)
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
    let dizh = dateProvider.currentDate.shichen?.dizhi ?? .zi

    let god = dateProvider.currentDate.twelveGod().map { "·" + $0.chinese } ?? ""
    
    MenuBarExtra(dateProvider.currentDate.displayStringOfChineseYearMonthDateWithZodiac + dizh.displayHourText + god) {
      MenuBarContentView(updater: dateProvider)
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
