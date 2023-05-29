//
//  LocationAnnotation.swift
//  petopia
//
//  Created by Winnie Ooi on 3/5/2023.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(title: String, lat: Double, long: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
    }

}
