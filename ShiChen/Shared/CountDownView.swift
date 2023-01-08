
import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CountDownView

struct CountDownView: View {
  var entry: ShichenTimelineProvider.Entry
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
  let dayConverter = DayConverter()
 

  var body: some View {
    let now: Date = .init()
    let event = dayConverter.find(day: .chuyi, month: .yin, inNextYears: 1).first ??
      .init(date: Date(), name: .chuyi, dateComponents: .init())
    let color = springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary

    let title = event.date.displayStringOfChineseYearMonthDateWithZodiac
    switch family {
    case .accessoryInline:
      Text("\(RelativeDateTimeFormatter.dateFormatter.localizedString(for: event.date, relativeTo: now))\(title)")
        .font(bodyFont)
    case .accessoryRectangular:
      HStack {
        Text(title)
          .font(bodyFont)
        Text(event.date, style: .relative)
          .font(bodyFont)
      }
    case .systemSmall:
      VStack(alignment: .leading) {
        Text("距離\(title)")
          Text(event.date, style: .relative)
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
        Text(event.date, style: .relative)
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
        CountDownView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .environment(\.locale, Locale(identifier: "zh_Hant"))
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
          .previewDisplayName("Inline")

        CountDownView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
          .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
          .previewDisplayName("Retangular")
      }
    }
    Group {
      CountDownView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      CountDownView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
    .environment(\.locale, Locale(identifier: "zh_Hant"))
    #endif
  }
}
