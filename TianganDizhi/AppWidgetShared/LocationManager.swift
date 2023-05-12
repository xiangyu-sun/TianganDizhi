
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
  
  let userDefault = Constants.sharedUserDefault
  
  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.LocationManager", category: "Model")
  
  var isAuthorizedForWidgetUpdates: Bool {
    service.isAuthorizedForWidgetUpdates
  }
  
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
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationContinuation?.resume(throwing: OperationError.didNotGetResult)
    locationContinuation = nil
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
 
      do {
        let encodedLocation = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false)
        userDefault?.set(encodedLocation, forKey: Constants.lastlocationKey)
        
        manager.stopUpdatingLocation()
      } catch {
        print(error)
      }
      
      locationContinuation?.resume(returning: location)
     
    } else {
      locationContinuation?.resume(throwing: OperationError.didNotGetResult)
    }
    
    locationContinuation = nil
  }
  
  // MARK: Private
  
  private var locationContinuation: CheckedContinuation<CLLocation, Error>?
  
  private let service = CLLocationManager()
}
