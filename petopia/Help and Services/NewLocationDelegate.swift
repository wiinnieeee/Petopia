//
//  NewLocationDelegate.swift
//  petopia
//  Delegate used to add a new annotation to a new location
//
//  Created by Winnie Ooi on 29/5/2023.
//

import Foundation

protocol NewLocationDelegate: NSObject {
    
    /// Add a new annotation to the map
    func annotationAdded (annotation: LocationAnnotation)
}
