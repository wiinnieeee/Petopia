//
//  User.swift
//  petopia
//
//  Created by Winnie Ooi on 11/5/2023.
//

import UIKit
import Foundation

class User: NSObject, Codable{
    var id: String?
    var name: String?
    var email: String?
    var listingList: [ListingAnimal] = []
    
    var phoneNumber: String?
    var address: String? = nil
}

