//
//  PetopiaUserDefaults.swift
//  petopia
//  Setup for light and dark mode user defaults
//
//  Created by Winnie Ooi on 30/5/2023.
//

import Foundation
import UIKit
import CoreLocation

struct PetopiaUserDefaults {
    // Static variable to declare te user defaults
    static var shared = PetopiaUserDefaults()
    
    /// Set and get the user defaults for the theme (view mode)
    var theme: Theme {
        get {
            return Theme(rawValue: UserDefaults.standard.integer(forKey: "selectedTheme")) ?? .device
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
        }
    }
    
    /// Set UserDefaults for the current user location
    func setLocation (location: CLLocation){
        let locationLat = NSNumber(value:location.coordinate.latitude)
        let locationLon = NSNumber(value:location.coordinate.longitude)
        UserDefaults.standard.set(["lat": locationLat, "lon": locationLon], forKey:"userLocation")
    }
    
    /// Get UserDefaults for the current user location
    func getLocation() -> CLLocation?
    {
        if let locationDictionary = UserDefaults.standard.object(forKey: "userLocation") as? Dictionary<String,NSNumber> {
            let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["lon"]!.doubleValue
            return CLLocation(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}
