//
//  ShichenHStackView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct ShichenHStackView: View {
    let shichen: Dizhi
    
    var body: some View {
        HStack() {
            VStack(){
                Text("\(shichen.previous.displayHourText)")
                    .font(.defaultTitle)
                ShichenInformationView(shichen: shichen.previous)
            }
            .foregroundColor(Color.secondary)
            
            Spacer()
            
            VStack(){
                Text("\(shichen.displayHourText)")
                    .font(.defaultTitle)
                    .scaleEffect(1.2)
                ShichenInformationView(shichen: shichen)
            }
            
            
            Spacer()
            VStack(){
                Text("\(shichen.next.displayHourText)")
                    .font(.defaultTitle)
                ShichenInformationView(shichen: shichen.next)
            }
            .foregroundColor(Color.secondary)
        }
    }
}

struct ShichenInformationView: View {
    let shichen: Dizhi
    
    var body: some View {
        HStack() {
            Text(shichen.aliasName)
                .font(.defaultFootnote)
            Text(shichen.organReference)
                .font(.defaultFootnote)
        }
    }
}

struct ShichenHStackView_Previews: PreviewProvider {
    static var previews: some View {
        ShichenHStackView(shichen: .zi)
    }
}
