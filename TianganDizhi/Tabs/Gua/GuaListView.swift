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
  @State private var navigationPath = NavigationPath()

  var body: some View {
    let _ = print("Loaded  GuaListView")
    NavigationStack(path: $navigationPath) {
      List {
        Section(header: Text("八卦")) {
          NavigationLink(value: GuaRoute.bagua(guas: xiantianBagua, title: "伏羲先天八卦")) {
            Text("伏羲先天八卦")
          }
          NavigationLink(value: GuaRoute.bagua(guas: houtianBagua, title: "文王後天八卦")) {
            Text("文王後天八卦")
          }
        }
        Section {
          NavigationLink(value: GuaRoute.shierPigua) {
            Text("陰曆十二辟卦")
          }
          NavigationLink(value: GuaRoute.yangliShierPigua) {
            Text("陽曆十二辟卦")
          }
        }
      }
      .font(bodyFont)
      .navigationTitle(Text("卦"))
      .navigationDestination(for: GuaRoute.self) { route in
        switch route {
        case .bagua(let guas, let title):
          BaguaView(viewData: .init(guas: guas, title: title))
        case .shierPigua:
          ShierPiguaView()
        case .yangliShierPigua:
          YangliShierPiguaView()
        }
      }
    }
  }
}

#Preview {
  GuaListView()
}
