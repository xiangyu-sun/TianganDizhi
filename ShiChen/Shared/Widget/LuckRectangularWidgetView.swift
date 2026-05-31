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

  // Day branch clash — derived from day pillar (constant throughout the day).
  private var chongDizhi: Dizhi? {
    guard let chars = Bazi(date: date)?.allCharacters, chars.count >= 6 else { return nil }
    let riZhiChar = chars[5]
    return Dizhi.allCases.first { $0.chineseCharacter == riZhiChar }?.chong
  }

  private var auspiceColor: Color {
    switch god?.xiongjiL {
    case "黃道": .green
    case "大凶": .red
    case "黑道": .orange
    default: .secondary
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      // Row 1: 沖 + Dizhi + zodiac | auspice badge
      HStack {
        if let chong = chongDizhi {
          Text("沖")
            .foregroundStyle(.secondary)
          
          Text(chong.chineseCharacter)
            .widgetAccentable()
          
          Text(Zodiac(chong).rawValue)
        }
        
        Spacer()
        
        if let god {
          Text(god.xiongjiL)
            .foregroundStyle(auspiceColor)
        }
      }
      .font(.body.bold())

      // Row 2: god name · 宜 keywords
      if let god {
        HStack() {
          Text(god.chinese)
            .widgetAccentable()
        }
        
      }
    }
    .font(.caption)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#if os(iOS)
#Preview {
  LuckRectangularWidgetView(date: .now)
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}
#endif
