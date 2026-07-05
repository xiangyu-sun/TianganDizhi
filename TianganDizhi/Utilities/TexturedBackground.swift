import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct TexturedBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(Constants.backgroundStyle, store: Constants.sharedUserDefault)
    var backgroundStyle = 0

    // Different texture region each launch; @State so the seed survives view
    // rebuilds — a plain `let` would re-roll and make the texture jump.
    @State private var seed = Float.random(in: 0..<1000)

    var body: some View {
        GeometryReader { geo in
            let isDark: Float = colorScheme == .dark ? 1.0 : 0.0
            let w = geo.size.width
            let h = geo.size.height
            Rectangle()
                .colorEffect(
                    backgroundStyle == 1
                        ? ShaderLibrary.stoneMarble(.float2(w, h), .float(isDark), .float(seed))
                        : ShaderLibrary.xuanPaper(.float2(w, h), .float(isDark), .float(seed), .image(Image("paperGrain")))
                )
        }
        .ignoresSafeArea()
    }
}
