//
//  ShichenView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct ShichenView: View {
    let currentShichen: Dizhi

    var body: some View {
        ZStack {
            ForEach(Dizhi.allCases, id: \.self) { dizhi in
                DizhiView(shichen: dizhi, current: self.currentShichen == dizhi  )
            }
        }
    }
}

private struct DizhiView: View {
    let shichen: Dizhi
    
    @Environment(\.titleFont) var titleFont
    
    var rotation: Double {
        Double((shichen.rawValue + 7) % 12)
    }
    let current: Bool
    var body: some View {
        VStack() {
            Text("\(shichen.chineseCharactor)")
                .font(titleFont)
                .foregroundColor(current ? Color.primary : Color.secondary)
                .scaleEffect(current ? 1.2 : 1)
                .rotationEffect(.radians(-(Double.pi * 2 / 12 * rotation)))
            
            Spacer()
        }
        .padding(25)
        .rotationEffect(.radians((Double.pi * 2 / 12 * rotation)))
    }
}

struct ShichenView_Previews: PreviewProvider {
    static var previews: some View {
        ShichenView(currentShichen: .zi)
            .scaledToFit()
    }
}
