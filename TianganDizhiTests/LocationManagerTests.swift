import CoreLocation
import Foundation
import Testing
@testable import TianganDizhi

/// Regression tests for the LocationManager continuation-leak bug: a single
/// `CheckedContinuation?` slot meant a second concurrent
/// `startLocationUpdate()` call (exactly what `MainView.onAppear` and
/// `scenePhase == .active` produce in quick succession) silently dropped
/// the first caller's continuation without resuming it — the awaiting Task
/// then hung forever.
///
/// `authorizationStatusOverride` lets these tests force the "authorized"
/// branch deterministically, independent of whatever permission state the
/// test host's simulator actually has, and the CoreLocation delegate
/// methods are invoked directly to simulate a location arriving — no real
/// GPS fix or system permission prompt is involved.
@MainActor
@Suite final class LocationManagerTests {

  @Test func concurrentCallersBothResolveOnASingleLocationUpdate() async throws {
    let manager = LocationManager()
    let sample = CLLocation(latitude: 37.3318, longitude: -122.0312)

    async let first = manager.startLocationUpdate(authorizationStatusOverride: .authorizedWhenInUse)
    async let second = manager.startLocationUpdate(authorizationStatusOverride: .authorizedWhenInUse)

    // Give both continuations a chance to register before the location arrives.
    try await Task.sleep(nanoseconds: 100_000_000)
    manager.locationManager(CLLocationManager(), didUpdateLocations: [sample])

    let (firstResult, secondResult) = try await (first, second)
    #expect(firstResult == sample, "the first caller's continuation must not be dropped by the second call")
    #expect(secondResult == sample)
  }

  @Test func failureResumesAllPendingCallers() async throws {
    let manager = LocationManager()

    async let first: CLLocation = manager.startLocationUpdate(authorizationStatusOverride: .authorizedWhenInUse)
    async let second: CLLocation = manager.startLocationUpdate(authorizationStatusOverride: .authorizedWhenInUse)

    try await Task.sleep(nanoseconds: 100_000_000)
    manager.locationManager(CLLocationManager(), didFailWithError: LocationManager.OperationError.didNotGetResult)

    var firstThrew = false
    do {
      _ = try await first
    } catch {
      firstThrew = true
    }
    var secondThrew = false
    do {
      _ = try await second
    } catch {
      secondThrew = true
    }

    #expect(firstThrew, "the first caller must also be resumed (with an error), not left hanging")
    #expect(secondThrew)
  }
}
