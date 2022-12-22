
import CoreLocation
import Foundation
import os
import WeatherKit

final class LocationManager: NSObject, CLLocationManagerDelegate {

  // MARK: Lifecycle

  override init() {
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

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.LocationManager", category: "Model")

  var isAuthorizedForWidgetUpdates: Bool {
    service.isAuthorizedForWidgetUpdates
  }

  func startLocationUpdate() async throws -> CLLocation {
    try await withCheckedThrowingContinuation { [unowned self] continuation in
      switch service.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        service.startUpdatingLocation()
        locationContinuation = continuation
      case .notDetermined:
        service.requestWhenInUseAuthorization()
        locationContinuation = continuation
      case .denied, .restricted:
        continuation.resume(throwing: OperationError.perimissionDeclied)
      @unknown default:
        continuation.resume(throwing: OperationError.didNotGetResult)
      }
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      service.startUpdatingLocation()
    case .notDetermined:
      break
    case .denied, .restricted:
      locationContinuation?.resume(throwing: OperationError.perimissionDeclied)
      locationContinuation = nil
    @unknown default:
      locationContinuation?.resume(throwing: OperationError.perimissionDeclied)
      locationContinuation = nil
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationContinuation?.resume(returning: location)
      manager.stopUpdatingLocation()
    } else {
      locationContinuation?.resume(throwing: OperationError.didNotGetResult)
    }

    locationContinuation = nil
  }

  // MARK: Private

  private var locationContinuation: CheckedContinuation<CLLocation, Error>?

  private let service = CLLocationManager()
}
