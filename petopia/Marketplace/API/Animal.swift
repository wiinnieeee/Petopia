//
//  Animal.swift
//  petopia
//
//  Created by Winnie Ooi on 15/5/2023.
//

import Foundation
import UIKit

struct Animal: Codable {

  var id             : Int?         = nil
  var url            : String?      = nil
  var type           : String?      = nil
  var species        : String?      = nil
  var breeds         : Breeds?      = Breeds()
  var age            : String?      = nil
  var gender         : String?      = nil
  var name           : String?      = nil
  var description    : String?      = nil
  var photos         : [Photos]?    = []
  var videos         : [Videos]?    = []
  var status         : String?      = nil
  var contact        : Contact?     = Contact()
   

  enum CodingKeys: String, CodingKey {

    case id             = "id"
    case url            = "url"
    case type           = "type"
    case species        = "species"
    case breeds         = "breeds"
    case age            = "age"
    case gender         = "gender"
    case name           = "name"
    case description    = "description"
    case photos         = "photos"
    case videos         = "videos"
    case status         = "status"
    case contact        = "contact"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id             = try values.decodeIfPresent(Int.self         , forKey: .id             )
    url            = try values.decodeIfPresent(String.self      , forKey: .url            )
    type           = try values.decodeIfPresent(String.self      , forKey: .type           )
    species        = try values.decodeIfPresent(String.self      , forKey: .species        )
    breeds         = try values.decodeIfPresent(Breeds.self      , forKey: .breeds         )
    age            = try values.decodeIfPresent(String.self      , forKey: .age            )
    gender         = try values.decodeIfPresent(String.self      , forKey: .gender         )
    name           = try values.decodeIfPresent(String.self      , forKey: .name           )
    description    = try values.decodeIfPresent(String.self      , forKey: .description    )
    photos         = try values.decodeIfPresent([Photos].self    , forKey: .photos         )
    videos         = try values.decodeIfPresent([Videos].self    , forKey: .videos         )
    status         = try values.decodeIfPresent(String.self      , forKey: .status         )
    contact        = try values.decodeIfPresent(Contact.self     , forKey: .contact        )
 
  }

  init() {

  }

}
