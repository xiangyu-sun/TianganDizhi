import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - FullDateTitleView

struct FullDateTitleView: View {
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = false

  var date: Date
  var god: String {
    date.twelveGod().map { $0.chinese } ?? ""
  }
  var body: some View {
    HStack {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac + " " + god)
      date.nextJieJiWithinOneDay.map{ Text($0) }
      if displayMoonPhaseOnWidgets {
        Text(date.chineseDay()?.moonPhase.name(traditionnal: useTranditionalNaming) ?? "")
      }
    }
  }
}

#Preview {
  FullDateTitleView(date: Date())
  #if os(watchOS)
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  #else
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  #endif
}
