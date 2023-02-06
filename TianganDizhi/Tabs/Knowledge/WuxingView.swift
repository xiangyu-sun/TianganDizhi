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
  @Environment(\.title3Font) var title3Font
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.footnote) var footnote
  
  @Environment(\.iPad) var iPad

  let columns = [
    GridItem(.flexible(), spacing: 0),
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(Wuxing.allCases, id: \.self) { item in
          let alignment: HorizontalAlignment = .leading
          HStack {
            VStack(alignment:alignment, spacing: 0) {
              Text("\(item.chineseCharacter)")
                .font(iPad ? largeTitleFont : title2Font)

              HStack {
                VStack(alignment: alignment, spacing: 0) {
                  Text("天干")
                    .font(footnote)
                  HStack {
                    Text("\(item.tiangan.0.chineseCharactor)")
                    Text("\(item.tiangan.1.chineseCharactor)")
                  }
                  .font(iPad ? title3Font : bodyFont)
                  Divider()
                  Text("地支")
                    .font(footnote)
                  HStack {
                    ForEach(item.dizhi) {
                      Text("\($0.chineseCharactor)")
                        .font(iPad ? title3Font : bodyFont)
                    }
                  }
                }
                .scaledToFit()

                Divider()

                VStack(alignment: alignment, spacing: 0) {
                  Text("臟腑和情緒")
                    .font(footnote)
                  HStack {
                    let wuzang = 五臟.allCases.first { $0.wuxing == item } ?? .心
                    Text("\(wuzang.rawValue)")

                    let wufu = 五腑.allCases.first { $0.wuxing == item } ?? .小腸
                    Text("\(wufu.rawValue)")
                    Text("\(wuzang.情緒)")
                  }
                  .font(iPad ? title3Font : bodyFont)

                  Divider()

                  Text("五味")
                    .font(footnote)
                  HStack {
                    Text("\(item.fiveFlavor)")
                      .font(iPad ? title3Font : bodyFont)
                  }
                }
                .scaledToFit()

                Divider()

                VStack {
                  Text("五音")
                    .font(footnote)
                  HStack {
                    Text("\(Key.wuyin.first { $0.wuxing == item }!.wuyinChineseName)")
                      .font(iPad ? title3Font : bodyFont)
                  }
                }
                Divider()

                VStack {
                  Text("方位")
                    .font(footnote)
                  HStack {
                    Text("\(item.fangwei.chineseCharactor)")
                      .font(iPad ? title3Font : bodyFont)
                    
                  }
                }
                VStack {
                  Text("色彩")
                    .font(footnote)
                  Text(item.colorDescription)
                    .font(iPad ? title3Font : bodyFont)
                }

                Divider()

                if let season = Season.allCases.first { $0.wuxing == item }?.chineseDescription {
                  VStack {
                    Text("四季")
                      .font(footnote)
                    HStack {
                      Text("\(season)")
                        .font(iPad ? title3Font : bodyFont)
                    }
                  }
                }
              }
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
