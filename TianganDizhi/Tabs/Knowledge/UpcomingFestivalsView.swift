import ChineseAstrologyCalendar
import SwiftUI

// MARK: - UpcomingFestivalsView

struct UpcomingFestivalsView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font
  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false

  @State private var upcomingEvents: [(festival: ChineseFestival, date: Date)] = []

  var body: some View {
    List(upcomingEvents, id: \.festival) { item in
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(item.festival.chineseName)
            .font(title3Font)
          Spacer()
          Text(item.date, style: .date)
            .font(bodyFont)
            .foregroundStyle(.secondary)
        }
        Text(item.date, style: .relative)
          .font(footnote)
          .foregroundStyle(.orange)
        Text(item.festival.meaning)
          .font(footnote)
          .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("\(item.festival.chineseName)，\(item.date.formatted(date: .long, time: .omitted))，\(item.festival.meaning)")
    }
    .navigationTitle("節日曆")
    .onAppear {
      if upcomingEvents.isEmpty {
        upcomingEvents = buildUpcomingEvents()
      }
    }
    .onChange(of: useGTM8) { _ in
      upcomingEvents = buildUpcomingEvents()
    }
  }

  private func buildUpcomingEvents() -> [(festival: ChineseFestival, date: Date)] {
    let converter = useGTM8 ? DayConverter(calendar: .chineseCalendarGTM8) : DayConverter()
    return ChineseFestival.allCases.compactMap { festival in
      guard let date = festival.nextDate(from: Date.now, converter: converter) else { return nil }
      return (festival, date)
    }
    .sorted { $0.date < $1.date }
  }
}

#Preview {
  NavigationStack {
    UpcomingFestivalsView()
  }
}
