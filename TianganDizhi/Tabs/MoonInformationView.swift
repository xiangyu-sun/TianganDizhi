import SwiftUI

struct MoonInformationView: View {
  @State var info: WeatherData.Information
  @Environment(\.bodyFont) var bodyFont
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false
  
  var body: some View {
    HStack() {
      Spacer()
      
      VStack(alignment: .leading) {
        HStack {
          if #available(iOS 16.0, watchOS 9.0, *) {
            Image(systemName: info.moonPhase.moonPhase.symbolName)
          }
          Text(info.moonPhase.name(traditionnal: useTranditionalNaming))
        }
        .font(bodyFont)
        HStack() {
          if let moonrise = info.moonRise {
            HStack(spacing: 0) {
              Text(moonrise, style: .time)
              Text("月升")
            }
            .font(bodyFont)
          }
          if let moonset = info.moonset {
            HStack(spacing: 0) {
              Text(moonset, style: .time)
              Text("月落")
            }
            .font(bodyFont)
          }
        }
      }
      .padding(.trailing)

    }
  }
}

@available(iOS 15, *)
struct MoonInformationView_Previews: PreviewProvider {
    static var previews: some View {
      SunInformationView(info: WeatherData.Information(moonPhase: .上弦月,
                                                   moonRise: .now,
                                                   moonset: .now,
                                                   sunrise: .now,
                                                   sunset: .now,
                                                   noon: .now,
                                                   midnight: .now,
                                                   temperatureHigh: .init(value: 12, unit: .celsius), temperatureLow: .init(value: 30, unit: .celsius),
                                                              condition: "ok"
                                                             )
      )
    }
}
