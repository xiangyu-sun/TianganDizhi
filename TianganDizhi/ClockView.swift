//
//  ClockView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

struct ClockView: View {
    var body: some View {
        
        Circle()
            .stroke(lineWidth: 8)
            .scale(0.8)
        .overlay(WedgesView())

    }
}

struct WedgesView: View {
    let ring = Ring.model
    
    var body: some View {
        let wedges = ZStack {
            ForEach(self.ring.wedgeIDs, id: \.self) { wedgeID in
                WedgeView(wedge: self.ring.wedges[wedgeID]!)
            }
            // Stop the window shrinking to zero when wedgeIDs.isEmpty.
            Spacer()
        }
        .flipsForRightToLeftLayoutDirection(true)
        .padding()

        // Wrap the wedge container in a drawing group so that
        // everything draws into a single CALayer using Metal. The
        // CALayer contents are rendered by the app, removing the
        // rendering work from the shared render server.

        let drawnWedges = wedges.drawingGroup()

        // Composite the ring of wedges under the buttons, over a white
        // background.

        return drawnWedges
    }
}

/// A view drawing a single colored ring wedge.
struct WedgeView: View {
    var wedge: Ring.Wedge
    
    var body: some View {
        
        WedgeShape(wedge).fill(wedge.foregroundGradient)
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
    }
}
