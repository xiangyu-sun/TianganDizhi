import Testing
@testable import TianganDizhi

/// A widget tap should land on the screen the widget shows, not just its tab.
@Suite struct AppRouterTests {

  @Test(arguments: ["Jieqi", "JieqiHealth", "com.uriphium.tinagandizhi.countdown.widget"])
  func jieqiWidgetsOpenJieqiList(kind: String) {
    #expect(AppRouter.destination(forWidgetKind: kind) == .knowledge)
    #expect(AppRouter.knowledgeRoute(forWidgetKind: kind) == .jieqiList)
  }

  @Test func festivalWidgetOpensFestivalCalendar() {
    #expect(AppRouter.knowledgeRoute(forWidgetKind: "SpecialDay") == .upcomingFestivals)
  }

  @Test func luckWidgetOpensTwelveGods() {
    #expect(AppRouter.knowledgeRoute(forWidgetKind: "LuckWidget") == .twelveGods)
  }

  /// Every widget routed into 天干地支 must be one the router sends to that tab,
  /// or the pending route would sit unconsumed until the user next visits it.
  @Test(arguments: ["ShiChen", "ShiChenByMinute", "Nongli", "CalendarWidget", "ShiChenStack", "unknown"])
  func timeWidgetsStayOnTabRoot(kind: String) {
    #expect(AppRouter.destination(forWidgetKind: kind) == .shichen)
    #expect(AppRouter.knowledgeRoute(forWidgetKind: kind) == nil)
  }
}
