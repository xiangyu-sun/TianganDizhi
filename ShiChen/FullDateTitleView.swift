import SwiftUI

import ChineseAstrologyCalendar

struct FullDateTitleView: View {

    @Environment(\.title3Font) var title3Font
    var date: Date
    var body: some View {
        HStack(){
            Text((try? GanzhiDateConverter.zodiac(date).rawValue) ?? "")
            Text(date.chineseYearMonthDate)
        }
        .font(title3Font)
    }
}
