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
/// The manager runs against `FakeLocationService`, so the only callbacks that
/// arrive are the ones each test delivers. With a real `CLLocationManager` the
/// simulator fired `didFailWithError` on its own, which failed the success test
/// and let the failure test pass whether or not the code under test worked.
@MainActor
@Suite(.timeLimit(.minutes(1))) final class LocationManagerTests {

  @Test func concurrentCallersBothResolveOnASingleLocationUpdate() async throws {
    let service = FakeLocationService(status: .authorizedWhenInUse)
    let manager = LocationManager(service: service)
    let sample = CLLocation(latitude: 37.3318, longitude: -122.0312)

    async let first = manager.startLocationUpdate()
    async let second = manager.startLocationUpdate()

    // Give both continuations a chance to register before the location arrives.
    try await Task.sleep(nanoseconds: 100_000_000)
    #expect(service.startCount == 2)
    manager.locationManager(CLLocationManager(), didUpdateLocations: [sample])

    let (firstResult, secondResult) = try await (first, second)
    #expect(firstResult == sample, "the first caller's continuation must not be dropped by the second call")
    #expect(secondResult == sample)
    #expect(service.stopCount == 1)
  }

  @Test func failureResumesAllPendingCallers() async throws {
    let service = FakeLocationService(status: .authorizedWhenInUse)
    let manager = LocationManager(service: service)

    let first = Task { try await manager.startLocationUpdate() }
    let second = Task { try await manager.startLocationUpdate() }

    try await Task.sleep(nanoseconds: 100_000_000)
    manager.locationManager(CLLocationManager(), didFailWithError: CLError(.locationUnknown))

    await #expect(throws: LocationManager.OperationError.didNotGetResult) { _ = try await first.value }
    await #expect(throws: LocationManager.OperationError.didNotGetResult) { _ = try await second.value }
  }

  @Test func deniedPermissionFailsImmediatelyWithoutStartingUpdates() async {
    let service = FakeLocationService(status: .denied)
    let manager = LocationManager(service: service)

    await #expect(throws: LocationManager.OperationError.perimissionDeclied) {
      _ = try await manager.startLocationUpdate()
    }
    #expect(service.startCount == 0)
  }
}

// MARK: - FakeLocationService

/// Records calls and never produces callbacks of its own.
private final class FakeLocationService: LocationService {
  init(status: CLAuthorizationStatus) {
    authorizationStatus = status
  }

  weak var delegate: (any CLLocationManagerDelegate)?
  var authorizationStatus: CLAuthorizationStatus
  var activityType = CLActivityType.other
  var desiredAccuracy = kCLLocationAccuracyBest
  var isAuthorizedForWidgetUpdates = false
  private(set) var startCount = 0
  private(set) var stopCount = 0

  func startUpdatingLocation() { startCount += 1 }
  func stopUpdatingLocation() { stopCount += 1 }
  func requestWhenInUseAuthorization() { }
}
