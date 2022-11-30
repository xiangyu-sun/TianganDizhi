import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - FullDateTitleView

struct FullDateTitleView: View {
  var date: Date
  var body: some View {
    Text(date.displayStringOfChineseYearMonthDateWithZodiac)
  }
}

// MARK: - FullDateTitleView_Previews

struct FullDateTitleView_Previews: PreviewProvider {
  static var previews: some View {
    FullDateTitleView(date: .now)
    #if os(watchOS)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    #else
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    #endif
  }
}
