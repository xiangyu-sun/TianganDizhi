//
//  LuckMediumWidgetView.swift
//  TianganDizhi
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - LuckMediumWidgetView

struct LuckMediumWidgetView: View {
  let date: Date

  private var god: TwelveGods? { date.twelveGod() }

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
    HStack(alignment: .top, spacing: 0) {
      // Left: god name + 宜
      VStack(alignment: .leading) {
        if let god {
          HStack(alignment: .top) {
            Text(god.chinese)
              .widgetAccentable()
            
            Text(god.xiongjiL)
              .foregroundStyle(auspiceColor)
              .background(auspiceColor.opacity(0.15), in: .capsule)
          }
          .font(.title2.bold())

          VStack(alignment: .leading) {
            Text("宜")
            Text(god.do)
          }
          .font(.caption)
        }
      }
      .frame(maxHeight: .infinity, alignment: .leading)

      Divider()

      // Right: 沖 + 忌
      VStack(alignment: .leading) {
        if let chong = chongDizhi {
          VStack(alignment: .leading) {
            HStack(alignment: .top) {
              Text("今日沖")
              
              Text(chong.chineseCharacter)
                .widgetAccentable()
              
              Text(Zodiac(chong).rawValue)
            
            }
            .font(.title2.bold())
          }
        }

        if let god {
          VStack(alignment: .leading) {
            Text("忌")
            Text(god.dontDo)
          }
          .font(.caption)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .ignoresSafeArea(.all)
    .materialBackgroundWidget(with: Image("background"), toogle: true)
    .widgetAccentable()
  }
}

#if os(iOS)
#Preview {
  LuckMediumWidgetView(date: .now)
}
#endif
