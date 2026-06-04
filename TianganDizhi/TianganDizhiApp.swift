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
    // TEMP DIAGNOSTIC: MenuBarExtra disabled to test WindowGroup visibility
    MenuBarExtra("天干地支") {
      MenuBarContentView()
    }
    #endif
  }

  // MARK: - Deep Link Handling

  private func handleDeepLink(_ url: URL) {
    guard url.scheme == "tiangandizhi" else { return }
    print("Deep link received: \(url)")
  }
}
