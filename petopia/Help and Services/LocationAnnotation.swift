//
//  LocationAnnotation.swift
//  petopia
//  Class to create a custom notification for the location pinned using MapKit
//
//  Created by Winnie Ooi on 3/5/2023.
//

import UIKit
import MapKit


class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    /// Initialisation of a Location Annotation to be called - use latitude and longitude to form a coordinate object
    init(title: String, lat: Double, long: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
    }

}
