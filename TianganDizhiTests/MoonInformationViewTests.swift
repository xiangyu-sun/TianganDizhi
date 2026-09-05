import Foundation
import Testing
@testable import TianganDizhi

/// A single `if let moonrise, let moonset` suppressed both rows whenever
/// either was nil — but WeatherKit legitimately returns only one on some
/// days. Each must render independently.
@Suite struct MoonInformationViewTests {

  @Test func bothPresentInChronologicalOrder() {
    let rise = Date(timeIntervalSince1970: 100)
    let set = Date(timeIntervalSince1970: 200)
    #expect(MoonInformationView.orderedMoonEvents(moonrise: rise, moonset: set) == [.rise(rise), .set(set)])
  }

  @Test func bothPresentSetBeforeRise() {
    let rise = Date(timeIntervalSince1970: 200)
    let set = Date(timeIntervalSince1970: 100)
    #expect(MoonInformationView.orderedMoonEvents(moonrise: rise, moonset: set) == [.set(set), .rise(rise)])
  }

  @Test func onlyMoonriseIsNotSuppressed() {
    let rise = Date(timeIntervalSince1970: 100)
    #expect(MoonInformationView.orderedMoonEvents(moonrise: rise, moonset: nil) == [.rise(rise)])
  }

  @Test func onlyMoonsetIsNotSuppressed() {
    let set = Date(timeIntervalSince1970: 100)
    #expect(MoonInformationView.orderedMoonEvents(moonrise: nil, moonset: set) == [.set(set)])
  }

  @Test func neitherPresentIsEmpty() {
    #expect(MoonInformationView.orderedMoonEvents(moonrise: nil, moonset: nil) == [])
  }
}
