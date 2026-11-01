import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - FullDateTitleView

struct FullDateTitleView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = false

  var date: Date
  var god: String {
    date.twelveGod().map { $0.localizedName(in: displayLanguage.glyphLanguage) } ?? ""
  }
  var body: some View {
    HStack {
      Text(date.lunarDateWithZodiac(language: displayLanguage) + " " + god)
      date.nextJieJiWithinOneDay.map{ Text($0) }
      if displayMoonPhaseOnWidgets {
        Text(date.chineseDay()?.moonPhase.name(traditionnal: useTranditionalNaming, language: displayLanguage) ?? "")
      }
    }
  }
}

#Preview {
  FullDateTitleView(date: Date())
}
