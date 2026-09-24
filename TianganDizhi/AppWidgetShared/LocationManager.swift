
import CoreLocation
import Foundation
import os
import WeatherKit

// MARK: - LocationService

/// The slice of `CLLocationManager` that `LocationManager` drives. Injectable so
/// tests control exactly which callbacks arrive — a real manager on the
/// simulator fires `didFailWithError` on its own, which resolved waiters before
/// a test's simulated location could land.
protocol LocationService: AnyObject {
  var delegate: (any CLLocationManagerDelegate)? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }
  var activityType: CLActivityType { get set }
  var desiredAccuracy: CLLocationAccuracy { get set }
  #if !os(watchOS)
  var isAuthorizedForWidgetUpdates: Bool { get }
  #endif
  func startUpdatingLocation()
  func stopUpdatingLocation()
  func requestWhenInUseAuthorization()
}

extension CLLocationManager: LocationService { }

// MARK: - LocationManager

@MainActor
final class LocationManager: NSObject, @MainActor CLLocationManagerDelegate {

  // MARK: Lifecycle

  init(service: any LocationService = CLLocationManager()) {
    self.service = service
    super.init()
    service.delegate = self
    service.activityType = .other
    service.desiredAccuracy = kCLLocationAccuracyThreeKilometers
  }

  // MARK: Internal

  enum OperationError: Error {
    case didNotGetResult
    case perimissionDeclied
  }

  static let shared = LocationManager()

  let userDefault = Constants.sharedUserDefault

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.LocationManager", category: "Location")

  #if !os(watchOS)
  var isAuthorizedForWidgetUpdates: Bool {
    service.isAuthorizedForWidgetUpdates
  }
  #endif

  var lastLocation: CLLocation? {
    if let data = userDefault?.object(forKey: Constants.lastlocationKey) as? Data {
      return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
    }
    return nil
  }

  func startLocationUpdate() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { [unowned self] continuation in
      switch service.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        locationContinuations.append(continuation)
        service.startUpdatingLocation()

      case .notDetermined:
        locationContinuations.append(continuation)
        service.requestWhenInUseAuthorization()
        // An app extension can never present the authorization prompt, so
        // the callback that would resolve this never arrives — without a
        // timeout the continuation, and the Task awaiting it, leak forever.
        if LocationManager.isRunningInAppExtension {
          Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self?.resumeAllWaiters(throwing: OperationError.didNotGetResult)
          }
        }

      case .denied, .restricted:
        continuation.resume(throwing: OperationError.perimissionDeclied)

      @unknown default:
        continuation.resume(throwing: OperationError.didNotGetResult)
      }
    }
  }

  func locationManagerDidChangeAuthorization(_: CLLocationManager) {
    switch service.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      // Only start updating on behalf of an actual caller — this delegate
      // method also fires once at `init`, before anyone has asked for a
      // location.
      if !locationContinuations.isEmpty {
        service.startUpdatingLocation()
      }

    case .notDetermined:
      break

    case .denied, .restricted:
      resumeAllWaiters(throwing: OperationError.perimissionDeclied)

    @unknown default:
      resumeAllWaiters(throwing: OperationError.perimissionDeclied)
    }
  }

  func locationManager(_: CLLocationManager, didFailWithError _: Error) {
    service.stopUpdatingLocation()
    resumeAllWaiters(throwing: OperationError.didNotGetResult)
  }

  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    service.stopUpdatingLocation()

    guard let location = locations.last else {
      resumeAllWaiters(throwing: OperationError.didNotGetResult)
      return
    }

    do {
      let encodedLocation = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false)
      userDefault?.set(encodedLocation, forKey: Constants.lastlocationKey)
    } catch {
      logger.error("Failed to archive location: \(error.localizedDescription)")
    }

    resumeAllWaiters(returning: location)
  }

  // MARK: Private

  private static let isRunningInAppExtension = Bundle.main.bundleURL.pathExtension == "appex"

  /// Every concurrent caller of `startLocationUpdate()` gets its own
  /// continuation appended here. A single-slot `CheckedContinuation?` would
  /// silently drop an earlier caller's continuation when a second call came
  /// in before the first resolved — exactly what happens when
  /// `MainView.refreshLocationAndWeather()` fires from both `.onAppear` and
  /// `scenePhase == .active` in quick succession — leaking that Task forever.
  private var locationContinuations: [CheckedContinuation<CLLocation, Error>] = []

  private let service: any LocationService

  private func resumeAllWaiters(returning location: CLLocation) {
    let waiters = locationContinuations
    locationContinuations.removeAll()
    for waiter in waiters {
      waiter.resume(returning: location)
    }
  }

  private func resumeAllWaiters(throwing error: Error) {
    let waiters = locationContinuations
    locationContinuations.removeAll()
    for waiter in waiters {
      waiter.resume(throwing: error)
    }
  }
}
