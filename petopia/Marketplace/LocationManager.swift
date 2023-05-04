//
//  LocationManager.swift
//  petopia
//
//  Created by Winnie Ooi on 4/5/2023.
//

import Foundation
import CoreLocation


struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D
    
}
class LocationManager: NSObject {
    static let shared = LocationManager()
    
    public func findLocations(with query: String, completion: @escaping(([Location]) -> Void)){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            let models: [Location] = places.compactMap({ place in
                var name = ""
                
                if let locName = place.name {
                    name += locName
                }
                
                if let adminReg = place.administrativeArea {
                    name += ", \(adminReg)"
                }
                
                if let localty = place.locality {
                    name += ", \(localty)"
                }
                
                if let country = place.country {
                    name += ", \(country)"
                }
                
                print ("\(place)\n\n")
                
                let result = Location(title: name, coordinates: place.location!.coordinate)
                return result
            })
            completion(models)
        }
    }
    
}

    
