//
//  WishlistAnimal.swift
//  petopia
//
//  Created by Winnie Ooi on 1/6/2023.
//
import Foundation
import UIKit

struct WishlistAnimal: Codable {
    var breed: String
    var age: String
    var gender: String
    var name: String
    var type: String
    var description: String
    var emailAddress: String
    var phoneNumber: String
    
    var imageID: String? = nil
    var imageURL: String? = nil
    var ownerID: String? = nil
}
