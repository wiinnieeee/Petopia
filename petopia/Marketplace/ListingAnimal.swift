//
//  ListingAnimal.swift
//  petopia
//  Details required to be known to create a listing for the pet
//
//  Created by Winnie Ooi on 2/6/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class ListingAnimal: NSObject, Codable {
    @DocumentID var id: String?
    var breed: String?
    var age: String?
    var gender: String?
    var name: String?
    var type: String?
    var desc: String?
    var emailAddress: String?
    var phoneNumber: String?
    var ownerID: String? = nil
    var imageID: String? = nil
    var imagePath: String? = nil
    var imageIsDownloading: Bool? = false
    var imageShown: Bool? = false

    enum CodingKeys: String, CodingKey {
            case id
            case breed
            case age
            case gender
            case name
            case type
            case desc
            case emailAddress
            case phoneNumber
            case ownerID
            case imageID
            case imagePath
            case imageIsDownloading
            case imageShown
    }
}



