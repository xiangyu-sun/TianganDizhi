//
//  LuckRectangularWidgetView.swift
//  TianganDizhi
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - LuckRectangularWidgetView

struct LuckRectangularWidgetView: View {
  let date: Date

  private var god: TwelveGods? { date.twelveGod() }
  private var chongDizhi: Dizhi? { date.shichen?.dizhi.chong }

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      // Row 1: god name + clash
      HStack(spacing: 4) {
        if let god {
          Text(god.chinese)
            .font(.headline)
            .widgetAccentable()
        }
        if let chong = chongDizhi {
          Text("·沖\(chong.chineseCharacter)\(Zodiac(chong).rawValue)")
            .font(.body)
            .foregroundStyle(.secondary)
        }
      }
      .lineLimit(1)

      // Row 2: 宜
      if let god {
        HStack(spacing: 2) {
          Text("宜")
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(god.do)
            .font(.caption2)
        }
        .lineLimit(1)

        // Row 3: 忌
        HStack(spacing: 2) {
          Text("忌")
            .font(.caption2)
            .foregroundStyle(.secondary)
          Text(god.dontDo)
            .font(.caption2)
        }
        .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .widgetAccentable()
  }
}

#if os(iOS)
#Preview {
  LuckRectangularWidgetView(date: .now)
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}
#endif
