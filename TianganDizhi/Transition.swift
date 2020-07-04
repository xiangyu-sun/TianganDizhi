//
//  Transition.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
/// The custom view modifier defining the transition applied to each
/// wedge view as it's inserted and removed from the display.
struct ScaleAndFade: ViewModifier {
    /// True when the transition is active.
    var isEnabled: Bool

    // Scale and fade the content view while transitioning in and
    // out of the container.

    func body(content: Content) -> some View {
        return content
            .scaleEffect(isEnabled ? 0.1 : 1)
            .opacity(isEnabled ? 0 : 1)
    }
}

extension AnyTransition {
    static let scaleAndFade = AnyTransition.modifier(
        active: ScaleAndFade(isEnabled: true),
        identity: ScaleAndFade(isEnabled: false))
}
