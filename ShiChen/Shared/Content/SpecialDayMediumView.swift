//
//  SpecialDayMediumView.swift
//  TianganDizhi
//
//  Copyright © 2026 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - SpecialDayMediumView

/// The medium 節氣與節日 widget: today's or the next special day with its
/// description, then the few after it — all from ``SpecialDayCatalog``, so it
/// lists the same days as the small widget and the 節日曆 screen.
///
/// Laid out like ``JieqiHealthMediumView``; a solar-term day keeps that
/// widget's term artwork as its background.
struct SpecialDayMediumView: View {

  // MARK: Internal

  let date: Date

  var body: some View {
    let events = date.upcomingSpecialDays(
      sources: SpecialDayCatalog.sources(),
      within: Self.lookahead,
      calendar: .solarTerm
    )

    if let featured = events.first {
      VStack(alignment: .leading, spacing: 4) {
        // The bundled LXGW font is kept to single-line names, which shrink to
        // fit. Multi-line and small text uses system text styles: WidgetKit
        // truncates custom-font CJK text instead of wrapping or fitting it.
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(featured.day.name)
            .font(title3Font)
            .minimumScaleFactor(0.6)

          Text(featured.daysUntil.daysUntilText)
            .font(.callout)
            .foregroundStyle(featured.daysUntil == 0 ? Color.orange : Color.secondary)

          Spacer(minLength: 0)

          Text(featured.day.date, format: Self.dayFormat)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .layoutPriority(1)
        }
        .lineLimit(1)

        if !featured.day.detail.isEmpty {
          Text(featured.day.detail)
            .font(.footnote)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)

        let later = events.dropFirst().prefix(3)
        if !later.isEmpty {
          HStack(spacing: 12) {
            ForEach(Array(later.enumerated()), id: \.offset) { _, event in
              VStack(alignment: .leading, spacing: 0) {
                Text(event.day.name)
                  .font(calloutFont)
                  .lineLimit(1)
                  .minimumScaleFactor(0.6)
                Text(event.daysUntil.daysUntilText)
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding(.horizontal, 8)
      .environment(\.locale, Locale(identifier: "zh-Hant"))
      .widgetAccentable()
      .containerBackground(for: .widget) {
        background(for: featured.day)
      }
    } else {
      Text(date.jieQiDisplayText)
        .font(title3Font)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
          Image("background")
            .resizable(resizingMode: .tile)
        }
    }
  }

  // MARK: Private

  /// Far enough ahead to always fill the row: solar terms are ~15 days apart.
  private static let lookahead = 120
  private static let dayFormat = Date.FormatStyle().month().day()

  @StateObject private var fontProvider = FontProvider()

  private var title3Font: Font { fontProvider.title3Font }
  private var calloutFont: Font { fontProvider.calloutFont }

  @ViewBuilder
  private func background(for day: SpecialDay) -> some View {
    if day.date.isJieqiDay(in: .solarTerm), let jieqi = day.date.jieqi(in: .solarTerm) {
#if os(macOS)
      Image(nsImage: jieqi.image)
        .resizable()
        .scaledToFill()
#else
      Image(uiImage: jieqi.image)
        .resizable()
        .scaledToFill()
#endif
    } else {
      Image("background")
        .resizable(resizingMode: .tile)
    }
  }
}
