import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - FullDateTitleView

struct FullDateTitleView: View {
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  var date: Date
  var body: some View {
    HStack {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac)
      Text(date.chineseDay()?.moonPhase.name(traditionnal: useTranditionalNaming) ?? "")
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
