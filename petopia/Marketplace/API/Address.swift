//
//  Address.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Address: Codable {

  var address1 : String? = nil
  var address2 : String? = nil
  var city     : String? = nil
  var state    : String? = nil
  var postcode : String? = nil
  var country  : String? = nil

  enum CodingKeys: String, CodingKey {

    case address1 = "address1"
    case address2 = "address2"
    case city     = "city"
    case state    = "state"
    case postcode = "postcode"
    case country  = "country"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    address1 = try values.decodeIfPresent(String.self , forKey: .address1 )
    address2 = try values.decodeIfPresent(String.self , forKey: .address2 )
    city     = try values.decodeIfPresent(String.self , forKey: .city     )
    state    = try values.decodeIfPresent(String.self , forKey: .state    )
    postcode = try values.decodeIfPresent(String.self , forKey: .postcode )
    country  = try values.decodeIfPresent(String.self , forKey: .country  )
 
  }

  init() {

  }

}
