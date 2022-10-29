//
//  ShichenHStackView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar
import WidgetKit

struct ShichenHStackView: View {
    let shichen: Dizhi
    @Environment(\.titleFont) var titleFont
    @Environment(\.shouldScaleFont) var shouldScaleFont
    @Environment(\.title2Font) var title2Font
    @Environment(\.widgetFamily) var family
    
    
    var body: some View {
        HStack() {
            VStack(){
                Text("\(shichen.previous.displayHourText)")
                    .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
                ShichenInformationView(shichen: shichen.previous)
            }
            .foregroundColor(Color.secondary)
            
            Spacer()
            
            VStack(){
                Text("\(shichen.displayHourText)")
                    .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
                    .scaleEffect(1.2)
                ShichenInformationView(shichen: shichen)
            }
            
            
            Spacer()
            VStack(){
                Text("\(shichen.next.displayHourText)")
                    .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
                ShichenInformationView(shichen: shichen.next)
            }
            .foregroundColor(Color.secondary)
        }
    }
}

struct ShichenInformationView: View {
    @Environment(\.shouldScaleFont) var shouldScaleFont
    @Environment(\.title2Font) var title2Font
    @Environment(\.widgetFamily) var family
    
    
    let shichen: Dizhi
    
    var body: some View {
        HStack() {
            Text(shichen.aliasName)
            Text(shichen.organReference)
        }
        #if os(iOS)
        .font((shouldScaleFont && family == .systemExtraLarge) ? title2Font : .defaultFootnote)
        #else
        .font(.defaultFootnote)
        #endif
        
    }
}

struct ShichenHStackView_Previews: PreviewProvider {
    static var previews: some View {
        ShichenHStackView(shichen: .zi)
            .padding()
    }
}
