
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CountDownView

struct CountDownView: View {
  @Environment(\.displayLanguage) private var displayLanguage
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
      ? event.date.lunarDateWithZodiacGTM8(language: displayLanguage)
      : event.date.lunarDateWithZodiac(language: displayLanguage)
  }

  var body: some View {
    let now = Date()
    let relative = RelativeDateTimeFormatter.countdown(for: displayLanguage).localizedString(for: event.date, relativeTo: now)
    // Chinese runs the countdown into the date; English needs a separator.
    let separator = displayLanguage.isChinese ? "" : " · "

    let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary

    switch family {
    case .accessoryInline:
      Text("\(relative)\(separator)\(title)")
        .font(.body)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .containerBackground(for: .widget) {
          Color.clear
        }

    case .accessoryRectangular:
      HStack {
        Text(title)
        Text(event.date, style: .relative)
      }
      .englishFit(displayLanguage, lines: 2, minimumScale: 0.7)
      .font(.headline)
      .containerBackground(for: .widget) {
        Color.clear
      }

    case .systemSmall:
      Text("\(relative) \(title)")
      .font(bodyFont)
      .englishFit(displayLanguage, lines: 5, minimumScale: 0.5)
      .foregroundStyle(color)
      .materialBackgroundWidget(with: Image("background"), toogle: true)

    default:
      VStack(alignment: .center) {
        FullDateTitleView(date: entry.date)
          .font(bodyFont)
        
        Text("\(relative)\(separator)\(title)")
          .font(title3Font)
          .englishFit(displayLanguage, lines: 3, minimumScale: 0.5)
      }
      .foregroundStyle(color)
      .materialBackgroundWidget(with: Image("background"), toogle: true)
    }
  }
}

#if os(iOS)
#Preview("Inline") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("Retangular") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemSmall") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
}

#Preview("systemMedium") {
  CountDownView(entry: CountDownEntry(date: Date(), configuration: ConfigurationIntent()))
}
#endif
