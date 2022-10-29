import SwiftUI
import ChineseAstrologyCalendar

@main
struct TianganDizhiApp: App {
    @ObservedObject var updater = DateProvider()
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    var body: some Scene {
        let dizh = try? GanzhiDateConverter.shichen(Date.now)
        WindowGroup {
            ContentView()
        }
#if os(macOS)
        MenuBarExtra((updater.currentDate.chineseYearMonthDate + dizh!.displayHourText )) {
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
