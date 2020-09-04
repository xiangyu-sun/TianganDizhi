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
                Text(shichen.previous.aliasName)
                    .font(.defaultFootnote)
            }
            .foregroundColor(Color.secondary)
            
            Spacer()
            VStack(){
                Text("\(shichen.displayHourText)")
                    .font(.defaultTitle)
                    .scaleEffect(1.2)
                Text(shichen.aliasName)
                    .font(.defaultFootnote)
            }
            
            
            Spacer()
            VStack(){
                Text("\(shichen.next.displayHourText)")
                    .font(.defaultTitle)
                Text(shichen.next.aliasName)
                    .font(.defaultFootnote)
            }
            .foregroundColor(Color.secondary)
        }
        .padding()
    }
}

struct ShichenHStackView_Previews: PreviewProvider {
    static var previews: some View {
        ShichenHStackView(shichen: .zi)
    }
}
