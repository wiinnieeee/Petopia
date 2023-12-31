//
//  Contact.swift
//  petopia
//  Contact details of the owner of the pet from the API
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Contact: Codable {

  var email   : String?  = nil
  var phone   : String?  = nil

  enum CodingKeys: String, CodingKey {

    case email   = "email"
    case phone   = "phone"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    email   = try values.decodeIfPresent(String.self  , forKey: .email   )
    phone   = try values.decodeIfPresent(String.self  , forKey: .phone   )
 
  }

  init() {

  }

}
