//
//  WuyinView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 1/5/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseTranditionalMusicCore
import MusicTheory

struct WuyinView: View {
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.title3Font) var title3Font

    var body: some View {
      VStack(alignment: .leading) {
        ForEach(Key.wuyin, id: \.self) { yin in
          HStack() {
            Text(yin.wuyinChineseName)
              .font(title3Font)
            Text("(\(yin.wuyinChineseName.transformToPinyin()))")
            
            Text("唐譜：\(yin.wuyinTangDynastySymbol)")
            Text("五行：\(yin.wuxing.chineseCharacter)")
            Text("唱名：\(yin.description)")
            
          }
          .font(bodyFont)
        }
        Spacer()
      }
      .navigationTitle("五音")
    }
}

struct WuyinView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView() {
        WuyinView()
      }
    }
}
