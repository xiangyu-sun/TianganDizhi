import Foundation
import Testing
@testable import TianganDizhi

/// `screen_view` must carry Firebase's recognized `firebase_screen`
/// parameter (`AnalyticsParameterScreenName`'s raw value) — the previous key
/// `screen_name` isn't a Firebase-recognized parameter, so every manually
/// logged screen view showed up in the Screens report as "(not set)".
@Suite struct AnalyticsServiceTests {

  @Test func screenViewUsesFirebaseRecognizedParameterName() {
    let params = AnalyticsService.Event.screenView(name: "KnowledgeDetail").parameters

    #expect(params?["firebase_screen"] as? String == "KnowledgeDetail")
    #expect(params?["screen_name"] == nil, "screen_name is not a Firebase-recognized parameter")
  }
}
