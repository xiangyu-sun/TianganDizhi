//
//  Environment.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 22/10/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

extension String {
    static let weibeiBold = "Weibei TC Bold"
}

private struct TitleFontEnvironmentKey: EnvironmentKey {
#if os(watchOS)
    static let defaultValue: Font = .defaultTitleWithSize(size: 28)
#else
    static let defaultValue: Font = .defaultTitleWithSize(size: 40)
#endif

}

private struct LargeTitleFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .defaultLargeTitleWithSize(size: 50)
}

private struct BodyFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .defaultBodyWithSize(size: 22)
}

private struct HeadlineFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .custom(.weibeiBold, size: 22, relativeTo: .headline)
}

private struct Title3FontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .custom(.weibeiBold, size: 26, relativeTo: .title3)
}

private struct Title2FontEnvironmentKey: EnvironmentKey {
    static let defaultValue: Font = .custom(.weibeiBold, size: 30, relativeTo: .title2)
}

private struct iPadEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad
#else
        false
#endif
    }
}

private struct ShouldScaleFontEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool {
#if os(iOS)
        UIScreen.main.bounds.width > 744
#else
        false
#endif
    }
    
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
    
    var title2Font: Font {
        get { self[Title2FontEnvironmentKey.self] }
        set { self[Title2FontEnvironmentKey.self] = newValue }
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
    var iPad: Bool {
        get { self[iPadEnvironmentKey.self] }
        set { }
    }
    
    var shouldScaleFont: Bool {
        get { self[ShouldScaleFontEnvironmentKey.self] }
        set { }
    }
    
}

extension View {
    func titleFont(_ myCustomValue: Font) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.titleFont, myCustomValue)
        }
#endif
        
        return environment(\.titleFont, TitleFontEnvironmentKey.defaultValue)
    }
    
    func title3Font(_ myCustomValue: Font) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.title3Font, myCustomValue)
        }
#endif
        return environment(\.title3Font, Title3FontEnvironmentKey.defaultValue)
    }
    
    func largeTitleFont(_ myCustomValue: Font) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.largeTitleFont, myCustomValue)
        }
#endif
        return environment(\.largeTitleFont, LargeTitleFontEnvironmentKey.defaultValue)
    }
    
    func bodyFont(_ myCustomValue: Font) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.bodyFont, myCustomValue)
        }
#endif
        return environment(\.bodyFont, BodyFontEnvironmentKey.defaultValue)
    }
    
    func headlineFont(_ myCustomValue: Font) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return environment(\.headlineFont, myCustomValue)
        }
#endif
        return environment(\.headlineFont, HeadlineFontEnvironmentKey.defaultValue)
    }
    
}
