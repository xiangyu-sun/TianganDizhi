import SwiftUI
import WidgetKit
import ChineseAstrologyCalendar

struct FullDateTitleView: View {

    @Environment(\.title3Font) var title3Font
    var date: Date
    var body: some View {
        Text(date.displayStringOfChineseYearMonthDateWithZodiac)
        .font(title3Font)
    }
}

struct FullDateTitleView_Previews: PreviewProvider {
    static var previews: some View {
        FullDateTitleView(date: .now)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
