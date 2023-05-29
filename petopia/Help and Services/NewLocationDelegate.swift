//
//  NewLocationDelegate.swift
//  petopia
//
//  Created by Winnie Ooi on 29/5/2023.
//

import Foundation

protocol NewLocationDelegate: NSObject {
    func annotationAdded (annotation: LocationAnnotation)
}
