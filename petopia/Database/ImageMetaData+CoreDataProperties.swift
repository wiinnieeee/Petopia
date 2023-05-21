//
//  ImageMetaData+CoreDataProperties.swift
//  petopia
//
//  Created by Winnie Ooi on 10/5/2023.
//
//

import Foundation
import CoreData


extension ImageMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageMetaData> {
        return NSFetchRequest<ImageMetaData>(entityName: "ImageMetaData")
    }

    @NSManaged public var fileName: String?

}

extension ImageMetaData : Identifiable {

}
