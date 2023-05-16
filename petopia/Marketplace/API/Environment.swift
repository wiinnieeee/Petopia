//
//  Environment.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Environment: Codable {

  var children : Bool? = nil
  var dogs     : Bool? = nil
  var cats     : Bool? = nil

  enum CodingKeys: String, CodingKey {

    case children = "children"
    case dogs     = "dogs"
    case cats     = "cats"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    children = try values.decodeIfPresent(Bool.self , forKey: .children )
    dogs     = try values.decodeIfPresent(Bool.self , forKey: .dogs     )
    cats     = try values.decodeIfPresent(Bool.self , forKey: .cats     )
 
  }

  init() {

  }

}
