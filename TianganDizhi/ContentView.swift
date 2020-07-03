//
//  ContentView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var date: Date
    
    var body: some View {
        VStack() {
            HStack() {
                Text(DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .medium))
                    .font(.body)
                Spacer()
            }.padding()
            HStack() {
                Text(date.year)
                    .font(.largeTitle)
                Spacer()
            }.padding()
            Spacer()
            Text(date.shichen)
                .font(.largeTitle)
            Spacer()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(date: Date())
    }
}
