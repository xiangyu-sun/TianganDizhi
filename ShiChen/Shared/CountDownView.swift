
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CountDownView

struct CountDownView: View {
  var entry: CountDownEntry
  @Environment(\.widgetFamily) var family
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.title2Font) var title2Font

  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  
  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false
  
  var dayConverter: DayConverter  {
    useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
  }
  

  var title: String {
    entry.configuration.parameter?.date?.displayStringOfChineseYearMonthDateWithZodiac ?? "n/a"
  }
  
  var date: Date {
    entry.configuration.parameter?.date ?? Date()
  }

  var body: some View {
    let now: Date = .init()
 
    let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary

    switch family {
    case .accessoryInline:
      Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: date, relativeTo: now))\(title)")
        .font(bodyFont)
    case .accessoryRectangular:
      HStack {
        Text(title)
          .font(bodyFont)
        Text(date, style: .relative)
          .font(bodyFont)
      }
    case .systemSmall:
      VStack(alignment: .leading) {
        Text("距離\(title)")
        Text(date, style: .relative)
      }
      .font(bodyFont)
      .foregroundColor(color)
      .padding([.leading, .trailing])
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackground(with: Image("background"), toogle: true)
    default:
      VStack(alignment: .center) {
        FullDateTitleView(date: entry.date)
          .font(title3Font)
        Text("距離\(title)")
          .font(title2Font)
        Text(date, style: .relative)
          .font(title3Font)
      }
      .foregroundColor(color)
      .padding([.trailing, .leading])
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackground(with: Image("background"), toogle: true)
    }
  }
}

// MARK: - CountDownView_Previews

struct CountDownView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(iOS)
    if #available(iOSApplicationExtension 16.0, *) {
      Group {
        CountDownView(entry: CountDownEntry(date: Date(), configuration: CountDownIntentConfigurationIntent()))
          .environment(\.locale, Locale(identifier: "zh_Hant"))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("Inline")

        CountDownView(entry: CountDownEntry(date: Date(), configuration: CountDownIntentConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("Retangular")
      }
    }
    Group {
      CountDownView(entry: CountDownEntry(date: Date(), configuration: CountDownIntentConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      CountDownView(entry: CountDownEntry(date: Date(), configuration: CountDownIntentConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
    .environment(\.locale, Locale(identifier: "zh_Hant"))
    #endif
  }
}
