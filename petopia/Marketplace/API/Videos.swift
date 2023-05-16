//
//  Videos.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Videos: Codable {

  var embed : String? = nil

  enum CodingKeys: String, CodingKey {

    case embed = "embed"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    embed = try values.decodeIfPresent(String.self , forKey: .embed )
 
  }

  init() {

  }

}
