//
//  Breeds.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation
import Foundation

struct Breeds: Codable {

  var primary   : String? = nil
  var secondary : String? = nil
  var mixed     : Bool?   = nil
  var unknown   : Bool?   = nil

  enum CodingKeys: String, CodingKey {

    case primary   = "primary"
    case secondary = "secondary"
    case mixed     = "mixed"
    case unknown   = "unknown"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    primary   = try values.decodeIfPresent(String.self , forKey: .primary   )
    secondary = try values.decodeIfPresent(String.self , forKey: .secondary )
    mixed     = try values.decodeIfPresent(Bool.self   , forKey: .mixed     )
    unknown   = try values.decodeIfPresent(Bool.self   , forKey: .unknown   )
 
  }

  init() {

  }

}
