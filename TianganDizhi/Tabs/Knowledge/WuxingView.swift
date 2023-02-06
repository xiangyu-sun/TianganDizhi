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
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.footnote) var footnote

  let columns = [
    GridItem(.flexible(), spacing: 0),
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(Wuxing.allCases, id: \.self) { item in
          HStack {
            VStack(alignment: .leading, spacing: 0) {
              Text("\(item.chineseCharacter)")
                .font(title2Font)

              HStack {
                VStack(alignment: .leading, spacing: 0) {
                  Text("天干")
                    .font(footnote)
                  HStack {
                    Text("\(item.tiangan.0.chineseCharactor)")
                    Text("\(item.tiangan.1.chineseCharactor)")
                  }
                  Divider()
                  Text("地支")
                    .font(footnote)
                  HStack {
                    ForEach(item.dizhi) {
                      Text("\($0.chineseCharactor)")
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

                  Divider()

                  Text("五味")
                    .font(footnote)
                  HStack {
                    Text("\(item.fiveFlavor)")
                  }
                }
                .scaledToFit()

                Divider()

                VStack {
                  Text("五音")
                    .font(footnote)
                  HStack {
                    Text("\(Key.wuyin.first { $0.wuxing == item }!.wuyinChineseName)")
                  }
                }
                Divider()

                VStack {
                  Text("方位")
                    .font(footnote)
                  HStack {
                    Text("\(item.fangwei.chineseCharactor)")
                  }
                }
                VStack {
                  Text("色彩")
                    .font(footnote)
                  Text(item.colorDescription)
                }

                Divider()

                if let season = Season.allCases.first { $0.wuxing == item }?.chineseDescription {
                  VStack {
                    Text("四季")
                      .font(footnote)
                    HStack {
                      Text("\(season)")
                    }
                  }
                }
              }
              .font(bodyFont)
            }
          }
        }
      }
      .padding()
    }
  }
}

// MARK: - WuxingView_Previews

struct WuxingView_Previews: PreviewProvider {
  static var previews: some View {
    WuxingView()
  }
}
