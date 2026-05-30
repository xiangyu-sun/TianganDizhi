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
    HStack(spacing: 0) {
      // Left: god name + 宜
      VStack(alignment: .leading, spacing: 6) {
        if let god {
          HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(god.chinese)
              .font(.title2.bold())
              .widgetAccentable()
            Text(god.xiongjiL)
              .font(.caption)
              .foregroundStyle(auspiceColor)
              .padding(.horizontal, 5)
              .padding(.vertical, 2)
              .background(auspiceColor.opacity(0.15), in: .capsule)
          }

          VStack(alignment: .leading, spacing: 2) {
            Text("宜")
              .font(.caption2)
              .foregroundStyle(.secondary)
            Text(god.do)
              .font(.caption)
              .lineLimit(3)
          }
        }
        Spacer()
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Divider()
        .padding(.vertical, 4)

      // Right: 沖 + 忌
      VStack(alignment: .leading, spacing: 6) {
        if let chong = chongDizhi {
          VStack(alignment: .leading, spacing: 2) {
            Text("今日沖")
              .font(.caption2)
              .foregroundStyle(.secondary)
            HStack(spacing: 2) {
              Text(chong.chineseCharacter)
                .font(.title2.bold())
                .widgetAccentable()
              Text(Zodiac(chong).rawValue)
                .font(.body)
            }
          }
        }

        if let god {
          VStack(alignment: .leading, spacing: 2) {
            Text("忌")
              .font(.caption2)
              .foregroundStyle(.secondary)
            Text(god.dontDo)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(3)
          }
        }
        Spacer()
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 8)
    }
    .padding()
    .widgetAccentable()
  }
}

#if os(iOS)
#Preview {
  LuckMediumWidgetView(date: .now)
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}
#endif
