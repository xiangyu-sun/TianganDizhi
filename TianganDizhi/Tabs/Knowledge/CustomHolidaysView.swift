//
//  CustomHolidaysView.swift
//  TianganDizhi
//
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - CustomHolidaysView

/// 自訂節日: the user's own yearly days, shown in 節日曆 and the 節氣與節日 widget.
struct CustomHolidaysView: View {

  // MARK: Internal

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.footnote) var footnote
  @AppStorage(Constants.customHolidays, store: Constants.sharedUserDefault)
  var customHolidayData = Data()

  var body: some View {
    List {
      if holidays.isEmpty {
        Text("添加生日、紀念日等每年重複的日子，它們會顯示在節日曆和「節氣與節日」小組件中。")
          .font(footnote)
          .foregroundStyle(.secondary)
      }
      ForEach(holidays) { holiday in
        Button {
          editing = holiday
        } label: {
          row(holiday)
        }
        .buttonStyle(.plain)
      }
      .onDelete(perform: delete)

      Button {
        editing = CustomHoliday(day: RecurringDay(name: "", reckoning: .lunar, month: 1, day: 1))
      } label: {
        Label("添加自訂節日", systemImage: "plus")
          .font(bodyFont)
      }
    }
    .navigationTitle("自訂節日")
    .sheet(item: $editing) { holiday in
      NavigationStack {
        CustomHolidayEditor(
          holiday: holiday,
          isNew: !holidays.contains { $0.id == holiday.id },
          onSave: save,
          onDelete: { delete(id: holiday.id) }
        )
      }
    }
  }

  // MARK: Private

  @State private var editing: CustomHoliday?

  private var holidays: [CustomHoliday] {
    CustomHolidayStore.decode(customHolidayData)
  }

  private func row(_ holiday: CustomHoliday) -> some View {
    let next = RecurringDaySource(days: [holiday.day], timeZone: .solarTerm)
      .nextOccurrence(of: holiday.day, onOrAfter: .now)
    return HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(holiday.day.name)
          .font(bodyFont)
        Text(holiday.day.dateText)
          .font(footnote)
          .foregroundStyle(.secondary)
      }
      Spacer()
      if let next {
        Text(Calendar.solarTerm.dateComponents([.day], from: Calendar.solarTerm.startOfDay(for: .now), to: next).day?.daysUntilText ?? "")
          .font(footnote)
          .foregroundStyle(.orange)
      }
    }
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  private func save(_ holiday: CustomHoliday) {
    var list = holidays
    let isNew: Bool
    if let index = list.firstIndex(where: { $0.id == holiday.id }) {
      list[index] = holiday
      isNew = false
    } else {
      list.append(holiday)
      isNew = true
    }
    store(list)
    AnalyticsService.log(.customHolidaySaved(reckoning: holiday.day.reckoning.rawValue, isNew: isNew))
  }

  private func delete(at offsets: IndexSet) {
    var list = holidays
    list.remove(atOffsets: offsets)
    store(list)
    AnalyticsService.log(.customHolidayDeleted)
  }

  private func delete(id: UUID) {
    store(holidays.filter { $0.id != id })
    AnalyticsService.log(.customHolidayDeleted)
  }

  private func store(_ list: [CustomHoliday]) {
    customHolidayData = CustomHolidayStore.encode(list)
    // Both widgets label days from SpecialDayCatalog.
    WidgetCenter.shared.reloadTimelines(ofKind: "SpecialDay")
    WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
  }
}

// MARK: - CustomHolidayEditor

struct CustomHolidayEditor: View {

  // MARK: Lifecycle

  init(holiday: CustomHoliday, isNew: Bool, onSave: @escaping (CustomHoliday) -> Void, onDelete: @escaping () -> Void) {
    _draft = State(initialValue: holiday)
    self.isNew = isNew
    self.onSave = onSave
    self.onDelete = onDelete
  }

  // MARK: Internal

  var body: some View {
    Form {
      Section {
        TextField("名稱，如：媽媽生日", text: $draft.day.name)
        TextField("備註（選填）", text: $draft.day.detail)
      }

      Section {
        Picker("曆法", selection: $draft.day.reckoning) {
          Text("農曆").tag(RecurringDay.Reckoning.lunar)
          Text("公曆").tag(RecurringDay.Reckoning.gregorian)
        }
        #if !os(watchOS)
        .pickerStyle(.segmented)
        #endif

        Picker("月", selection: $draft.day.month) {
          ForEach(1...12, id: \.self) { month in
            Text(RecurringDay.monthText(month, reckoning: draft.day.reckoning)).tag(month)
          }
        }

        Picker("日", selection: $draft.day.day) {
          ForEach(1...maxDay, id: \.self) { day in
            Text(RecurringDay.dayText(day, reckoning: draft.day.reckoning)).tag(day)
          }
        }
      } footer: {
        Text(footerText)
      }

      if !isNew {
        Section {
          Button("刪除", role: .destructive) {
            onDelete()
            dismiss()
          }
        }
      }
    }
    .navigationTitle(isNew ? "添加自訂節日" : "編輯自訂節日")
    .onChange(of: draft.day.reckoning) { _, _ in
      draft.day.day = min(draft.day.day, maxDay)
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("取消") { dismiss() }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("儲存") {
          draft.day.name = trimmedName
          onSave(draft)
          dismiss()
        }
        .disabled(trimmedName.isEmpty)
      }
    }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @State private var draft: CustomHoliday
  private let isNew: Bool
  private let onSave: (CustomHoliday) -> Void
  private let onDelete: () -> Void

  private var trimmedName: String {
    draft.day.name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var maxDay: Int {
    draft.day.reckoning == .lunar ? 30 : 31
  }

  private var footerText: String {
    var text = "\(draft.day.dateText)，每年重複。"
    if let next = RecurringDaySource(days: [draft.day], timeZone: .solarTerm).nextOccurrence(of: draft.day, onOrAfter: .now) {
      text += "下次：\(next.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh-Hant"))))。"
    }
    text += "若當月沒有這一天（如農曆小月的三十、非閏年的2月29日），則在當月最後一天。"
    return text
  }
}

#Preview {
  NavigationStack {
    CustomHolidaysView()
  }
}
