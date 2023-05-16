//
//  Attributes.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation

struct Attributes: Codable {

  var spayedNeutered : Bool?   = nil
  var houseTrained   : Bool?   = nil
  var declawed       : String? = nil
  var specialNeeds   : Bool?   = nil
  var shotsCurrent   : Bool?   = nil

  enum CodingKeys: String, CodingKey {

    case spayedNeutered = "spayed_neutered"
    case houseTrained   = "house_trained"
    case declawed       = "declawed"
    case specialNeeds   = "special_needs"
    case shotsCurrent   = "shots_current"
  
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    spayedNeutered = try values.decodeIfPresent(Bool.self   , forKey: .spayedNeutered )
    houseTrained   = try values.decodeIfPresent(Bool.self   , forKey: .houseTrained   )
    declawed       = try values.decodeIfPresent(String.self , forKey: .declawed       )
    specialNeeds   = try values.decodeIfPresent(Bool.self   , forKey: .specialNeeds   )
    shotsCurrent   = try values.decodeIfPresent(Bool.self   , forKey: .shotsCurrent   )
 
  }

  init() {

  }

}
