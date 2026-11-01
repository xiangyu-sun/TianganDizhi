import ChineseAstrologyCalendar
import SwiftUI
import JingluoShuxue

// MARK: - WatchStackView

struct WatchStackView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let date: Date

  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  var body: some View {
    VStack {
      FullDateTitleView(date: date)
        .font(.footnote)
      if let shichen = date.shichen {
        HStack {
          VStack {
            Text("\(shichen.dizhi.previous.localizedHourName(in: displayLanguage.glyphLanguage))")
              .font(.footnote)
            ShichenWatchInformationView(shichen: shichen.dizhi.previous)
          }
          .foregroundStyle(Color.secondary)

          VStack {
            Text("\(shichen.dizhi.localizedHourName(in: displayLanguage.glyphLanguage))")
              .font(.footnote)
              .scaleEffect(1.1)

            ShichenWatchInformationView(shichen: shichen.dizhi)
          }

          VStack {
            Text("\(shichen.dizhi.next.localizedHourName(in: displayLanguage.glyphLanguage))")
              .font(.footnote)

            ShichenWatchInformationView(shichen: shichen.dizhi.next)
          }
          .foregroundStyle(Color.secondary)
        }
      }
    }
    .widgetAccentable()
    .foregroundStyle(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .containerBackground(for: .widget) {
      Color.black
    }
  }
}

// MARK: - ShichenWatchInformationView

struct ShichenWatchInformationView: View {
  @Environment(\.displayLanguage) private var displayLanguage

  let shichen: Dizhi
  var body: some View {
    HStack {
      Text(shichen.aliasName.converted(to: displayLanguage))
      Text(shichen.luizhu.organReference.converted(to: displayLanguage))
    }
    .widgetAccentable()
    .font(.footnote)
  }

}
