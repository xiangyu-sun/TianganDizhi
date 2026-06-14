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

// MARK: - GuaListView

struct GuaListView: View {
  @Environment(\.bodyFont) var bodyFont
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        Section(header: Text("八卦")) {
          NavigationLink(value: GuaRoute.bagua(guas: xiantianBagua, title: "伏羲先天八卦")) {
            Text("伏羲先天八卦")
          }
          .accessibilityLabel("伏羲先天八卦：伏羲創作的先天八卦排列方式")
          NavigationLink(value: GuaRoute.bagua(guas: houtianBagua, title: "文王後天八卦")) {
            Text("文王後天八卦")
          }
          .accessibilityLabel("文王後天八卦：文王創作的後天八卦排列方式")
        }
        Section(header: Text("辟卦")) {
          NavigationLink(value: GuaRoute.shierPigua) {
            Text("陰曆十二辟卦")
          }
          .accessibilityLabel("陰曆十二辟卦：農曆月份對應的辟卦")
          NavigationLink(value: GuaRoute.yangliShierPigua) {
            Text("陽曆十二辟卦")
          }
          .accessibilityLabel("陽曆十二辟卦：西曆月份對應的辟卦")
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
