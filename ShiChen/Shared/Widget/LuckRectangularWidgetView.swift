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
    HStack {
      if let god {
        HStack() {
          Text(god.chinese)

        }
      }
      
      if let chong = chongDizhi {
        Text("沖")
        Text(chong.chineseCharacter)
 
        Text(Zodiac(chong).rawValue)
      }
      
      Spacer()
      
      if let god {
        Text(god.xiongjiL)
          .foregroundStyle(auspiceColor)
      }
    }
    .containerBackground(for: .widget, content: {
      Color.clear
    })
    .widgetAccentable()
    .font(.body)
  }
}

#if os(iOS)
#Preview {
  LuckRectangularWidgetView(date: .now)
}
#endif
