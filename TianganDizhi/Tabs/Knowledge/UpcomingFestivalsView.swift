import ChineseAstrologyCalendar
import SwiftUI

// MARK: - UpcomingFestivalsView

/// 節日曆: every festival, solar term and 自訂節日 in the coming year, from the
/// same ``SpecialDayCatalog`` sources as the 節氣與節日 widget.
struct UpcomingFestivalsView: View {

  // MARK: Internal

  /// Which kinds of day the list shows.
  enum Filter: String, CaseIterable, Identifiable {
    case all = "全部"
    case festival = "節日"
    case jieqi = "節氣"
    case custom = "自訂"

    var id: Self { self }

    func includes(_ kind: SpecialDayKind) -> Bool {
      switch self {
      case .all: true
      case .festival: kind == .festival
      case .jieqi: kind == .jieqi
      case .custom: kind == .custom
      }
    }
  }

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @Environment(\.title3Font) var title3Font
  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false
  @AppStorage(Constants.customHolidays, store: Constants.sharedUserDefault)
  var customHolidayData = Data()

  var body: some View {
    List {
      Section {
        Picker("類別", selection: $filter) {
          ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
        }
        #if !os(watchOS)
        .pickerStyle(.segmented)
        #endif
      }

      Section {
        if visibleEvents.isEmpty {
          Text(filter == .custom ? "尚未添加自訂節日" : "一年內沒有節日")
            .font(bodyFont)
            .foregroundStyle(.secondary)
        }
        ForEach(visibleEvents, id: \.id) { item in
          row(item)
        }
      }

      Section {
        NavigationLink(value: KnowledgeRoute.customHolidays) {
          Label("管理自訂節日", systemImage: "calendar.badge.plus")
            .font(bodyFont)
        }
      }
    }
    .navigationTitle("節日曆")
    .onAppear {
      if events.isEmpty { rebuild() }
    }
    .onChange(of: useGTM8) { _, _ in rebuild() }
    .onChange(of: customHolidayData) { _, _ in rebuild() }
  }

  // MARK: Private

  private struct Event {
    let id: String
    let day: SpecialDay
    let daysUntil: Int
  }

  @State private var events: [Event] = []
  @State private var filter = Filter.all

  private var visibleEvents: [Event] {
    events.filter { filter.includes($0.day.kind) }
  }

  private func row(_ item: Event) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(item.day.name)
          .font(title3Font)
        Text(item.day.category)
          .font(footnote)
          .foregroundStyle(.secondary)
        Spacer()
        Text(item.day.date, style: .date)
          .font(bodyFont)
          .foregroundStyle(.secondary)
      }
      Text(item.daysUntil.daysUntilText)
        .font(footnote)
        .foregroundStyle(.orange)
      if !item.day.detail.isEmpty {
        Text(item.day.detail)
          .font(footnote)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(item.day.name)，\(item.day.category)，\(item.day.date.formatted(date: .long, time: .omitted))，\(item.daysUntil.daysUntilText)，\(item.day.detail)"
    )
  }

  private func rebuild() {
    // `useGTM8` is read through `TimeZone.solarTerm`; the custom days come
    // straight from the observed storage so an edit shows up at once.
    let sources = SpecialDayCatalog.sources(customHolidays: CustomHolidayStore.decode(customHolidayData))
    events = Date.now
      .upcomingSpecialDays(sources: sources, within: 365, calendar: .solarTerm)
      .map { Event(id: "\($0.daysUntil)|\($0.day.kind.rawValue)|\($0.day.name)", day: $0.day, daysUntil: $0.daysUntil) }
  }
}

#Preview {
  NavigationStack {
    UpcomingFestivalsView()
  }
}
