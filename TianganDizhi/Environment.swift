//
//  Environment.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 22/10/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

private struct TitleFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .defaultTitleWithSize(size: 40)
}

private struct LargeTitleFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .defaultLargeTitleWithSize(size: 50)
}

private struct BodyFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .defaultBodyWithSize(size: 22)
}


extension EnvironmentValues {
    var titleFont: Font {
        get { self[TitleFontEnvironmentKey.self] }
        set { self[TitleFontEnvironmentKey.self] = newValue }
    }
    
    var largeTitleFont: Font {
        get { self[LargeTitleFontEnvironmentKey.self] }
        set { self[LargeTitleFontEnvironmentKey.self] = newValue }
    }
    
    var bodyFont: Font {
        get { self[BodyFontEnvironmentKey.self] }
        set { self[BodyFontEnvironmentKey.self] = newValue }
    }
}

extension View {
    func titleFont(_ myCustomValue: Font) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.titleFont, myCustomValue)
        }
        return environment(\.titleFont, TitleFontEnvironmentKey.defaultValue)
    }
    
    func largeTitleFont(_ myCustomValue: Font) -> some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.largeTitleFont, myCustomValue)
        }
        return environment(\.largeTitleFont, LargeTitleFontEnvironmentKey.defaultValue)
    }
    
    func bodyFont(_ myCustomValue: Font) -> some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.bodyFont, myCustomValue)
        }
        return environment(\.bodyFont, BodyFontEnvironmentKey.defaultValue)
    }
}
