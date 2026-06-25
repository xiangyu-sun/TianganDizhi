
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CountDownView

struct CountDownView: View {
  var entry: CountDownEntry
  @Environment(\.widgetFamily) var family
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.headlineFont) var headlineFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.title2Font) var title2Font

  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false

  var dayConverter: DayConverter {
    useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
  }

  var event: EventModel {
    dayConverter.find(day: .day1, month: .yin, inNextYears: 1).first ??
      .init(date: Date(), name: .day1, dateComponents: .init())
  }

  var title: String {
    useGTM8
      ? event.date.displayStringOfChineseYearMonthDateWithZodiacGTM8
      : event.date.displayStringOfChineseYearMonthDateWithZodiac
  }

  var body: some View {
    let now = Date()

    let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary

    switch family {
    case .accessoryInline:
      Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: event.date, relativeTo: now))\(title)")
        .font(.body)
        .containerBackgroundForWidget {
          Color.clear
        }

    case .accessoryRectangular:
      HStack {
        Text(title)
        Text(event.date, style: .relative)
      }
      .font(.headline)
      .containerBackgroundForWidget {
        Color.clear
      }

    case .systemSmall:
      Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: event.date, relativeTo: now)) \(title)")
      .font(bodyFont)
      .foregroundStyle(color)
      .materialBackgroundWidget(with: Image("background"), toogle: true)

    default:
      VStack(alignment: .center) {
        FullDateTitleView(date: entry.date)
          .font(bodyFont)
        
        Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: event.date, relativeTo: now))\(title)")
          .font(title3Font)
      }
      .foregroundStyle(color)
      .materialBackgroundWidget(with: Image("background"), toogle: true)
    }
  }
}

#if os(iOS)
#Preview("Inline") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryInline))
}

#Preview("Retangular") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}

#Preview {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemSmall))
}

#Preview {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}
#endif
