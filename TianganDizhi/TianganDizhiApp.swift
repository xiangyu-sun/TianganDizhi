import SwiftUI
import ChineseAstrologyCalendar
import Firebase

@main
struct TianganDizhiApp: App {
    init() {
        FirebaseApp.configure()
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: .weibeiBold, size: 34)!]
        UITabBarItem.appearance().setTitleTextAttributes([.font : UIFont(name: .weibeiBold, size: 12)!], for: [])
    }
    
    @ObservedObject var updater = DateProvider()
    
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
