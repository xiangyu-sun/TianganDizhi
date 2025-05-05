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
  var body: some View {
    HStack {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac)
      date.nextJieQi.map{ Text($0.description) }
      if displayMoonPhaseOnWidgets {
        Text(date.chineseDay()?.moonPhase.name(traditionnal: useTranditionalNaming) ?? "")
      }
    }
    .containerBackgroundForWidget {
      Color.clear
    }
  }
}

// MARK: - FullDateTitleView_Previews

struct FullDateTitleView_Previews: PreviewProvider {
  static var previews: some View {
    FullDateTitleView(date: Date())
    #if os(watchOS)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    #else
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    #endif
  }
}
