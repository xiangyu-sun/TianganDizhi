//
//  CornerView.swift
//  ShichenWatch Watch App
//
//  Created by Xiangyu Sun on 24/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CornerView: View {
    var body: some View {
        ZStack() {
            AccessoryWidgetBackground()
        }
        widgetLabel{
            Gauge(value: 1) {
                Text("mg")
            } currentValueLabel: {
                Text("current")
            } minimumValueLabel: {
                Text("shi")
            } maximumValueLabel: {
                Text("chen")
            }

        }
    }
}

struct CornerView_Previews: PreviewProvider {
    static var previews: some View {
        CornerView()
    }
}
