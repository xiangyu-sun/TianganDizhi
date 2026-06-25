import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct MarbleBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(Constants.backgroundStyle, store: Constants.sharedUserDefault)
    var backgroundStyle = 0

    var body: some View {
        GeometryReader { geo in
            let isDark: Float = colorScheme == .dark ? 1.0 : 0.0
            let w = geo.size.width
            let h = geo.size.height
            Rectangle()
                .colorEffect(
                    backgroundStyle == 1
                        ? ShaderLibrary.stoneMarble(.float2(w, h), .float(isDark))
                        : ShaderLibrary.marble(.float2(w, h), .float(isDark))
                )
        }
        .ignoresSafeArea()
    }
}
