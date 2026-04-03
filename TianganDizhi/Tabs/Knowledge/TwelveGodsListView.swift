//
//  TianganListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI



struct TwelveGodsListView: View {
  let twelveGods = TwelveGods.allCases
  @State private var currentPage:TwelveGods = .establish
  
  var body: some View {
#if os(watchOS)
    List(twelveGods, id: \.self) {
      TwelveGodCell(god: $0)
    }
#elseif os(iOS)
    TabView(selection: $currentPage) {
      ForEach(twelveGods, id: \.self) { god in
        Image(god.pinYinWithoutAccent)
          .resizable()
          .scaledToFit()
          .ignoresSafeArea()
          .accessibilityHidden(true)
          .tag(god)
          .overlay(
            TwelveGodCell(god: god)
          )
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
#else
    TabView(selection: $currentPage) {
      ForEach(twelveGods, id: \.self) { god in
        Image(god.pinYinWithoutAccent)
          .resizable()
          .scaledToFit()
          .ignoresSafeArea()
          .accessibilityHidden(true)
          .tag(god)
          .overlay(
            TwelveGodCell(god: god)
          )
      }
    }
#endif

  }
}

// MARK: - TianganCell

struct TwelveGodCell: View {
  let god: TwelveGods
  @Environment(\.bodyFont) var bodyFont
  var body: some View {
      VStack(alignment: .leading){
        Spacer()
        Group() {
#if os(watchOS)
          Text("\(god.chinese)")
#endif
          Text("\(god.meaning)")
          Text("宜：\(god.do)")
          Text("忌：\(god.dontDo)")
        }
        .background(.ultraThinMaterial)
      }
      .padding()
      .font(bodyFont)
      .accessibilityElement(children: .combine)
      .accessibilityLabel("\(god.chinese)，\(god.meaning)，宜：\(god.do)，忌：\(god.dontDo)")
  }
}

#Preview {
  TwelveGodsListView()
}
