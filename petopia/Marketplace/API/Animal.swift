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
  var organizationId : String?      = nil
  var url            : String?      = nil
  var type           : String?      = nil
  var species        : String?      = nil
  var breeds         : Breeds?      = Breeds()
  var colors         : Colors?      = Colors()
  var age            : String?      = nil
  var gender         : String?      = nil
  var size           : String?      = nil
  var coat           : String?      = nil
  var tags           : [String]?    = []
  var name           : String?      = nil
  var description    : String?      = nil
  var photos         : [Photos]?    = []
  var videos         : [Videos]?    = []
  var status         : String?      = nil
  var publishedAt    : String?      = nil
  var contact        : Contact?     = Contact()
    
    // Used to track image downloads:
    var image: UIImage?
    var imageIsDownloading: Bool = false
    var imageShown = true

  enum CodingKeys: String, CodingKey {

    case id             = "id"
    case organizationId = "organization_id"
    case url            = "url"
    case type           = "type"
    case species        = "species"
    case breeds         = "breeds"
    case colors         = "colors"
    case age            = "age"
    case gender         = "gender"
    case size           = "size"
    case coat           = "coat"
    case tags           = "tags"
    case name           = "name"
    case description    = "description"
    case photos         = "photos"
    case videos         = "videos"
    case status         = "status"
    case publishedAt    = "published_at"
    case contact        = "contact"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id             = try values.decodeIfPresent(Int.self         , forKey: .id             )
    organizationId = try values.decodeIfPresent(String.self      , forKey: .organizationId )
    url            = try values.decodeIfPresent(String.self      , forKey: .url            )
    type           = try values.decodeIfPresent(String.self      , forKey: .type           )
    species        = try values.decodeIfPresent(String.self      , forKey: .species        )
    breeds         = try values.decodeIfPresent(Breeds.self      , forKey: .breeds         )
    colors         = try values.decodeIfPresent(Colors.self      , forKey: .colors         )
    age            = try values.decodeIfPresent(String.self      , forKey: .age            )
    gender         = try values.decodeIfPresent(String.self      , forKey: .gender         )
    size           = try values.decodeIfPresent(String.self      , forKey: .size           )
    coat           = try values.decodeIfPresent(String.self      , forKey: .coat           )
    tags           = try values.decodeIfPresent([String].self    , forKey: .tags           )
    name           = try values.decodeIfPresent(String.self      , forKey: .name           )
    description    = try values.decodeIfPresent(String.self      , forKey: .description    )
    photos         = try values.decodeIfPresent([Photos].self    , forKey: .photos         )
    videos         = try values.decodeIfPresent([Videos].self    , forKey: .videos         )
    status         = try values.decodeIfPresent(String.self      , forKey: .status         )
    publishedAt    = try values.decodeIfPresent(String.self      , forKey: .publishedAt    )
    contact        = try values.decodeIfPresent(Contact.self     , forKey: .contact        )
 
  }

  init() {

  }

}
