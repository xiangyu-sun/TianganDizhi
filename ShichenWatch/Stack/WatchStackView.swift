import ChineseAstrologyCalendar
import SwiftUI

// MARK: - WatchStackView

@available(watchOS 10.0, *)
struct WatchStackView: View {
  let date: Date

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @Environment(\.footnote) var footnote

  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  var body: some View {
    VStack {
      FullDateTitleView(date: date)
        .font(footnote)
      if let shichen = date.shichen {
        HStack {
          VStack {
            Text("\(shichen.dizhi.previous.displayHourText)")
              .font(footnote)
            ShichenWatchInformationView(shichen: shichen.dizhi.previous)
          }
          .foregroundColor(Color.secondary)

          VStack {
            Text("\(shichen.dizhi.displayHourText)")
              .font(footnote)
              .scaleEffect(1.1)

            ShichenWatchInformationView(shichen: shichen.dizhi)
          }

          VStack {
            Text("\(shichen.dizhi.next.displayHourText)")
              .font(footnote)

            ShichenWatchInformationView(shichen: shichen.dizhi.next)
          }
          .foregroundColor(Color.secondary)
        }
      }
    }
    .widgetAccentable()
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .containerBackground(for: .widget) {
      Color.black
    }
  }
}

// MARK: - ShichenWatchInformationView

struct ShichenWatchInformationView: View {

  let shichen: Dizhi
  @Environment(\.footnote) var footnote

  var body: some View {
    HStack {
      Text(shichen.aliasName)
      Text(shichen.organReference)
    }
    .widgetAccentable()
    .font(footnote)
  }

}
