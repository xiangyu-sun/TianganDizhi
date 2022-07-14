//
//  ClockView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct CircularContainerView: View {
    let currentShichen: Dizhi
    let padding: CGFloat

    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 4)
            ShichenView(currentShichen: currentShichen)
                .padding(padding)
        }
        .fixedSize(horizontal: false, vertical: true)
        
    }
}

struct CircularContainerView_Previews: PreviewProvider {
    static var previews: some View {
      Group() {
        CircularContainerView(currentShichen: .chen, padding: 0)
        CircularContainerView(currentShichen: .chen, padding: 0)
      }
    }
}
