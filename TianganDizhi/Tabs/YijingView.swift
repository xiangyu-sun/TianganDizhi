import SwiftUI
import Bagua

// MARK: - YijingView

struct YijingView: View {

  var body: some View {
    VStack(spacing: 20) {
      ForEach(hexagramSymbols) { hexagram in
        HStack {
          Text(hexagram.symbol)
            .font(.system(size: 48))
            .frame(width: 60)

          Text(hexagram.chineseCharacter)
            .font(.system(size: 24))
            .frame(width: 120)
        }
      }
    }
  }
}

// MARK: - YijingView_Previews

struct YijingView_Previews: PreviewProvider {
  static var previews: some View {
    YijingView()
  }
}
