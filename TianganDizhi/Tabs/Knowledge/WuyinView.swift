//
//  WuyinView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 1/5/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import ChineseTranditionalMusicCore
import MusicTheory
import SwiftUI

// MARK: - WuyinView

struct WuyinView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font

  var body: some View {
    List(Key.wuyin, id: \.self) { yin in
      VStack(alignment: .leading) {
        HStack {
          Text(yin.wuyinChineseName)
            .font(title3Font)
          Text("(\(yin.wuyinChineseName.transformToPinyin()))")
        }
        HStack {
          Text("唐譜：\(yin.wuyinTangDynastySymbol)")
          Text("五行：\(yin.wuxing.chineseCharacter)")
          Text("唱名：\(yin.description)")
        }
      }

      .font(bodyFont)
    }
    .navigationTitle("五音")
  }
}

// MARK: - WuyinView_Previews

struct WuyinView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      WuyinView()
    }
  }
}
