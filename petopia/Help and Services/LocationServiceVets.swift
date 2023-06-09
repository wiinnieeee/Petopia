//
//  LocationServiceVets.swift
//  petopia
//  Ask for authorization to get user locations
//  And manage the updating of locations accordingly
//  Reference: https://www.youtube.com/watch?v=YCmZayf7Zi4
//
//  Created by Winnie Ooi on 29/5/2023.
//

import Foundation
import CoreLocation

class LocationServiceVets: NSObject, CLLocationManagerDelegate {
    
    // Static variable to call the methods in LocationService
    static let shared = LocationServiceVets()
    
    // Initialise and configure the Location Manager
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    // Variable to check if location is updated
    var locationUpdated: ((CLLocationCoordinate2D) -> Void)?
    
    // Request permission to access the location
    override private init() {
        super.init()
        self.requestPermissionToAccessLocation()
    }
    
        
    
    // Call methods based on the authorization status
    // If authorized, location would start to be updated
    func requestPermissionToAccessLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case.restricted:
            locationManager.requestWhenInUseAuthorization()
        case.denied:
            break
        case  .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    // Check if the authorization status is changed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(manager.authorizationStatus.rawValue)
        switch manager.authorizationStatus {
            case  .authorizedAlways:
                manager.startUpdatingLocation()
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
            default:
                print("error with location change")
                break
            }
    }
    
    // Check if location updated
    // Stop location update after most recent location is obtained
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations.last is the most recent location update
        if let location = locations.last?.coordinate {
            locationManager.stopUpdatingLocation()

            
            locationUpdated?(location)
            
        }
    }
    
    // If location update fail, show error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
