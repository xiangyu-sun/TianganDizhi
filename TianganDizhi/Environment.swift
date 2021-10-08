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

private struct HeadlineFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .custom("Weibei TC Bold", size: 22, relativeTo: .headline)
}

private struct Title3FontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .custom("Weibei TC Bold", size: 26, relativeTo: .title3)
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
    
    var title3Font: Font {
        get { self[Title3FontEnvironmentKey.self] }
        set { self[Title3FontEnvironmentKey.self] = newValue }
    }
    
    var bodyFont: Font {
        get { self[BodyFontEnvironmentKey.self] }
        set { self[BodyFontEnvironmentKey.self] = newValue }
    }
    
    var headlineFont: Font {
        get { self[HeadlineFontEnvironmentKey.self] }
        set { self[HeadlineFontEnvironmentKey.self] = newValue }
    }
}

extension View {
    func titleFont(_ myCustomValue: Font) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.titleFont, myCustomValue)
        }
        return environment(\.titleFont, TitleFontEnvironmentKey.defaultValue)
    }
    
    func title3Font(_ myCustomValue: Font) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.title3Font, myCustomValue)
        }
        return environment(\.title3Font, Title3FontEnvironmentKey.defaultValue)
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
    
    func headlineFont(_ myCustomValue: Font) -> some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.headlineFont, myCustomValue)
        }
        return environment(\.headlineFont, HeadlineFontEnvironmentKey.defaultValue)
    }
    
}
