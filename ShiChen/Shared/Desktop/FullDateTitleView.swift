import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - FullDateTitleView

struct FullDateTitleView: View {
  var date: Date
  var body: some View {
    HStack() {
      Text(date.displayStringOfChineseYearMonthDateWithZodiac)
      Text(date.chineseDay?.moonPhase.rawValue ?? "")
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
