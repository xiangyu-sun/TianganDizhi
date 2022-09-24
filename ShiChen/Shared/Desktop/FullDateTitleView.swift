import SwiftUI
import WidgetKit
import ChineseAstrologyCalendar

struct FullDateTitleView: View {
    var date: Date
    var body: some View {
        Text(date.displayStringOfChineseYearMonthDateWithZodiac)
    }
}

struct FullDateTitleView_Previews: PreviewProvider {
    static var previews: some View {
        FullDateTitleView(date: .now)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
