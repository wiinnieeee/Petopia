//
//  Posts.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import Foundation
import FirebaseFirestoreSwift

// Post object
struct Posts: Codable {
    @DocumentID var id: String?
    var name: String?
    var date: Date?
    var title: String?
    var content: String?
    var comments: [Comments]?
}
