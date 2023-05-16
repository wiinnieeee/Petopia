//
//  Colors.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Colors: Codable {

  var primary   : String? = nil
  var secondary : String? = nil
  var tertiary  : String? = nil

  enum CodingKeys: String, CodingKey {

    case primary   = "primary"
    case secondary = "secondary"
    case tertiary  = "tertiary"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    primary   = try values.decodeIfPresent(String.self , forKey: .primary   )
    secondary = try values.decodeIfPresent(String.self , forKey: .secondary )
    tertiary  = try values.decodeIfPresent(String.self , forKey: .tertiary  )
 
  }

  init() {

  }

}
