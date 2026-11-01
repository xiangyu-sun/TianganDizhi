//
//  WuxingView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 18/11/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import JingluoShuxue
import MusicTheory
import SwiftUI

// MARK: - WuxingView

struct WuxingView: View {

  // MARK: Internal

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.title3Font) var title3Font
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.footnote) var footnote
  @Environment(\.displayLanguage) var displayLanguage

  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let columns = [
    GridItem(.flexible(), spacing: 0),
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(Wuxing.allCases, id: \.self) { item in
          content(item: item)
        }
      }
      .padding()
    }
  }

  func content(item: Wuxing) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .firstTextBaseline) {
          Text("\(item.chineseCharacter)")
            .font(horizontalSizeClass != .compact ? largeTitleFont : title2Font)
          if !displayLanguage.isChinese {
            Text(item.localizedName(in: displayLanguage))
              .font(title3Font)
              .foregroundStyle(.secondary)
          }
        }

        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("天干")
              .font(footnote)
            HStack {
              Text("\(item.tiangan.0.chineseCharacter)")
              Text("\(item.tiangan.1.chineseCharacter)")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            Divider()
            Text("地支")
              .font(footnote)
            HStack {
              ForEach(item.dizhi) {
                Text("\($0.chineseCharacter)")
                  .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
              }
            }
          }
          .scaledToFit()

          Divider()

          VStack(alignment: .leading, spacing: 0) {
            Text("臟腑和情緒")
              .font(footnote)
            HStack {
              let wuzang = 五臟.allCases.first { $0.wuxing == item } ?? .心
              GlossedText(glyph: wuzang.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : wuzang.localizedName(in: displayLanguage))

              let wufu = 五腑.allCases.first { $0.wuxing == item } ?? .小腸
              GlossedText(glyph: wufu.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : wufu.localizedName(in: displayLanguage))
              // 情緒 is library prose, which exists only in Chinese.
              Text("\(wuzang.情緒.converted(to: displayLanguage))")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)

            Divider()

            Text("五味")
              .font(footnote)
            HStack {
              GlossedText(glyph: item.localizedFlavor(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : item.localizedFlavor(in: displayLanguage))
                .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            }
          }
          .scaledToFit()

          Divider()
          makeTopicView(title: "五音", detail: "\(Key.wuyin.first { $0.wuxing == item }?.localizedWuyinName(in: displayLanguage) ?? "")")

          Divider()

          makeTopicView(title: "方位", detail: "\(item.fangwei.localizedName(in: displayLanguage.glyphLanguage))", gloss: displayLanguage.isChinese ? "" : item.fangwei.localizedName(in: displayLanguage))
          makeTopicView(title: "色彩", detail: "\(item.localizedColorDescription(in: displayLanguage.glyphLanguage))", gloss: displayLanguage.isChinese ? "" : item.localizedColorDescription(in: displayLanguage))

          Divider()

          if let season = Season.allCases.first(where: { $0.wuxing == item }) {
            makeTopicView(title: "四季", detail: season.localizedName(in: displayLanguage.glyphLanguage), gloss: displayLanguage.isChinese ? "" : season.localizedName(in: displayLanguage))
          }
        }
      }
    }
    .accessibilityElement(children: .combine)
  }

  // MARK: Fileprivate

  fileprivate func makeTopicView(title: LocalizedStringKey, detail: String, gloss: String = "") -> some View {
    VStack {
      Text(title)
        .font(footnote)
      HStack {
        GlossedText(glyph: detail, gloss: gloss, alignment: .center)
          .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
      }
    }
  }
}

#Preview {
  WuxingView()
}
