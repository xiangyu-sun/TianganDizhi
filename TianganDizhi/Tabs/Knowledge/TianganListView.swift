//
//  TianganListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - TianganListView

struct TianganListView: View {
  let tiangan = Tiangan.allCases
  var body: some View {
    List(tiangan, id: \.self) {
      TianganCell(tiangan: $0)
    }
    .navigationTitle("十天干")
  }
}

// MARK: - TianganCell

struct TianganCell: View {
  let tiangan: Tiangan
  @Environment(\.bodyFont) var bodyFont
  var body: some View {
    HStack {
      Text(tiangan.chineseCharacter)
      Text("(\(tiangan.chineseCharacter.transformToPinyin()))")
    }
    .padding()
    .font(bodyFont)
  }
}

// MARK: - TianganListView_Previews

struct TianganListView_Previews: PreviewProvider {
  static var previews: some View {
    TianganListView()
  }
}
