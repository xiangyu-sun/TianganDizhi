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
  @State private var currentPage:TwelveGods = .jian
  
  var body: some View {
    TabView(selection: $currentPage) {
      ForEach(twelveGods, id: \.self) { god in
        Image(god.pinYinWithoutAccent)
          .resizable()
          .scaledToFit()
          .ignoresSafeArea()
          .tag(god)
          .overlay(
            TwelveGodCell(god: god)
          )
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}

// MARK: - TianganCell

struct TwelveGodCell: View {
  let god: TwelveGods
  @Environment(\.bodyFont) var bodyFont
  var body: some View {
    if #available(iOS 15.0, watchOS 10.0, *) {
      VStack(alignment: .leading){
        Spacer()
        Group() {
          Text("\(god.meaning)")
          Text("\(god.do)")
          Text("\(god.dontDo)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing])
        .background(.ultraThinMaterial)
      }
      .font(bodyFont)
      
    } else {
      VStack(alignment: .leading){
        Spacer()
        Text("\(god.meaning)")
        Text("\(god.do)")
        Text("\(god.dontDo)")
      }
      .padding()
      .font(bodyFont)
    }
  }
}

// MARK: - TianganListView_Previews

struct TwelveGodsListView_Previews: PreviewProvider {
  static var previews: some View {
    TwelveGodsListView()
  }
}
