
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
    dayConverter.find(day: .chuyi, month: .yin, inNextYears: 1).first ??
      .init(date: Date(), name: .chuyi, dateComponents: .init())
  }

  var title: String {
    useGTM8
      ? event.date.displayStringOfChineseYearMonthDateWithZodiacGTM8
      : event.date.displayStringOfChineseYearMonthDateWithZodiac
  }

  var body: some View {
    let now: Date = .init()

    let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary

    switch family {
    case .accessoryInline:
      Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: event.date, relativeTo: now))\(title)")
        .font(bodyFont)
        .containerBackgroundForWidget {
          Color.clear
        }
    case .accessoryRectangular:
      HStack {
        Text(title)
        Text(event.date, style: .relative)
      }
      .font(headlineFont)
      .containerBackgroundForWidget {
        Color.clear
      }
    case .systemSmall:
      VStack(alignment: .leading) {
        Text("距離\(title)")
        Text(event.date, style: .relative)
          .environment(\.locale, Locale.current)
      }
      .font(bodyFont)
      .foregroundColor(color)
      .materialBackgroundWidget(with: Image("background"), toogle: true)
    default:
      VStack(alignment: .center) {
        FullDateTitleView(date: entry.date)
          .font(title3Font)
        Spacer(minLength: 4)
        Text("距離\(title)")
          .font(title3Font)
        Text(event.date, style: .relative)
          .environment(\.locale, Locale.current)
          .font(title3Font)
        Spacer()
      }
      .foregroundColor(color)
      .padding([.trailing, .leading])
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .materialBackgroundWidget(with: Image("background"), toogle: true)
    }
  }
}

// MARK: - CountDownView_Previews

struct CountDownView_Previews: PreviewProvider {
  static var previews: some View {
    #if os(iOS)
    if #available(iOSApplicationExtension 16.0, *) {
      Group {
        CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("Inline")

        CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("Retangular")
      }
    }
    Group {
      CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
    #endif
  }
}
