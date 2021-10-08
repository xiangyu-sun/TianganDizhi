//
//  JieqiCircularView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI

import ChineseAstrologyCalendar

struct JieqiCircularView: View {
    @State var currentJieqi: Jieqi?

    var body: some View {
        ZStack {
            ForEach(Jieqi.allCases, id: \.self) { jieqi in
                JieqiView(jieqi: jieqi, selectedJieqi: $currentJieqi) {jieqie in
                    currentJieqi = jieqi
                }
            }
        }
    }
}

private struct JieqiView: View {
    let jieqi: Jieqi
    @Environment(\.bodyFont) var bodyFont
    var rotation: Double {
        Double((jieqi.rawValue + 90))
    }
    @Binding var selectedJieqi: Jieqi?
    
    var onTap: (Jieqi) -> Void?
    
    var body: some View {
        VStack() {
            Text("\(jieqi.chineseName)")
                .font(bodyFont)
                .foregroundColor(selectedJieqi == jieqi ? Color.primary : Color.secondary)
                .scaleEffect(selectedJieqi == jieqi ? 1.2 : 1)
                .rotationEffect(.degrees(-rotation))
            Spacer()
        }
        .rotationEffect(.degrees(rotation))
        .onTapGesture {
            onTap(jieqi)
        }
    }
}

struct JieqiCircularView_Previews: PreviewProvider {
    static var previews: some View {
        JieqiCircularView(currentJieqi: .guyu)
            .scaledToFit()
    }
}
