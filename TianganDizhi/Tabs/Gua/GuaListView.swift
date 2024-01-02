//
//  GuaListView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 5/12/23.
//  Copyright © 2023 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import SwiftUI

// MARK: - KnowledgeView

struct GuaListView: View {
  @Environment(\.bodyFont) var bodyFont

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("八卦")) {
          NavigationLink(destination: BaguaView(viewData: .init(guas: xiantianBagua, title: "伏羲先天八卦"))) {
            Text("伏羲先天八卦")
          }
          NavigationLink(destination: BaguaView(viewData: .init(guas: houtianBagua, title: "文王後天八卦"))) {
            Text("文王後天八卦")
          }
        }
        Section {
          NavigationLink(destination: ShierPiguaView()) {
            Text("十二辟卦")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("卦"))
    }
  }
}

#Preview {
  GuaListView()
}
