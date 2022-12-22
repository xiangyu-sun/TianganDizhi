
import Foundation
import WeatherKit
import CoreLocation
import os


final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    enum OperationError: Error {
        case didNotGetResult
        case perimissionDeclied
    }
    
    let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.LocationManager", category: "Model")
    
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    static let shared = LocationManager()
    
    private let service = CLLocationManager()
    
    var isAuthorizedForWidgetUpdates: Bool {
        service.isAuthorizedForWidgetUpdates
    }
    
    override init() {
        super.init()
        service.delegate = self
        service.activityType = .other
        service.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func startLocationUpdate() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
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
    
}

