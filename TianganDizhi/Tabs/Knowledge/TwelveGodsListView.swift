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
  let tiangan = TwelveGods.allCases
  var body: some View {
    List(tiangan, id: \.self) {
      TwelveGodCell(god: $0)
    }
    .navigationTitle("十天干")
  }
}

// MARK: - TianganCell

struct TwelveGodCell: View {
  let god: TwelveGods
  @Environment(\.bodyFont) var bodyFont
  var body: some View {
    HStack {
      Text(god.chinese)
      Text("(\(god.chinese.transformToPinyin()))")
      Spacer()
      Text("\(god.meaning)")
      Text("\(god.do)")
      Text("\(god.dontDo)")
    }
    .padding()
    .font(bodyFont)
  }
}

// MARK: - TianganListView_Previews

struct TwelveGodsListView_Previews: PreviewProvider {
  static var previews: some View {
    TwelveGodsListView()
  }
}
