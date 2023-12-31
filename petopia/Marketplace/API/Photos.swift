//
//  Photos.swift
//  petopia
//  Photos of the pet in four different forms from the API
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation
import UIKit

struct Photos: Codable {

  var small  : String? = nil
  var medium : String? = nil
  var large  : String? = nil
  var full   : String? = nil


  enum CodingKeys: String, CodingKey {

    case small  = "small"
    case medium = "medium"
    case large  = "large"
    case full   = "full"
  
  }
    
    // Values to decode
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    small  = try values.decodeIfPresent(String.self , forKey: .small  )
    medium = try values.decodeIfPresent(String.self , forKey: .medium )
    large  = try values.decodeIfPresent(String.self , forKey: .large  )
    full   = try values.decodeIfPresent(String.self , forKey: .full   )
 
  }

  init() {

  }

}
