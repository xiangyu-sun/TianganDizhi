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
        Text("\(item.chineseCharacter)")
          .font(horizontalSizeClass != .compact ? largeTitleFont : title2Font)

        HStack {
          VStack(alignment: .leading, spacing: 0) {
            Text("天干")
              .font(footnote)
            HStack {
              Text("\(item.tiangan.0.chineseCharactor)")
              Text("\(item.tiangan.1.chineseCharactor)")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            Divider()
            Text("地支")
              .font(footnote)
            HStack {
              ForEach(item.dizhi) {
                Text("\($0.chineseCharactor)")
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
              Text("\(wuzang.rawValue)")

              let wufu = 五腑.allCases.first { $0.wuxing == item } ?? .小腸
              Text("\(wufu.rawValue)")
              Text("\(wuzang.情緒)")
            }
            .font(horizontalSizeClass != .compact ? title3Font : bodyFont)

            Divider()

            Text("五味")
              .font(footnote)
            HStack {
              Text("\(item.fiveFlavor)")
                .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
            }
          }
          .scaledToFit()

          Divider()
          makeTopicView(title: "五音", detail: "\(Key.wuyin.first { $0.wuxing == item }?.wuyinChineseName ?? "")")

          Divider()

          makeTopicView(title: "方位", detail: "\(item.fangwei.chineseCharactor)")
          makeTopicView(title: "色彩", detail: "\(item.colorDescription)")

          Divider()

          if let season = Season.allCases.first(where: { $0.wuxing == item })?.chineseDescription {
            makeTopicView(title: "四季", detail: season)
          }
        }
      }
    }
  }

  // MARK: Fileprivate

  fileprivate func makeTopicView(title: String, detail: String) -> VStack<TupleView<(Text, HStack<Text>)>> {
    VStack {
      Text(title)
        .font(footnote)
      HStack {
        Text(detail)
          .font(horizontalSizeClass != .compact ? title3Font : bodyFont)
      }
    }
  }
}

// MARK: - WuxingView_Previews

struct WuxingView_Previews: PreviewProvider {
  static var previews: some View {
    WuxingView()
  }
}
