//
//  Wishlist.swift
//  petopia
//
//  Created by Winnie Ooi on 24/5/2023.
//

import Foundation

struct Wishlist: Codable{
    var id: String?
    var wishlist: [Animal] = []
}
