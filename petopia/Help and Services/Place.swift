//
//  Place.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// Details of the place fetched from MapKit
struct Place {
    var name: String?
    var phoneNumber: String?
    var coordinates: CLLocation?
    var url: URL?
    var distanceFromUser: String?
    var annotation: MKAnnotation?
}
