//
//  ClockView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct ClockView: View {
    var currentShichen: Dizhi
    var body: some View {
        ZStack{
            Circle()
            .stroke(lineWidth: 2)
            ShichenView(currentShichen: currentShichen).padding()
        }
        .scaledToFit()
        
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView(currentShichen: .chen)
    }
}
