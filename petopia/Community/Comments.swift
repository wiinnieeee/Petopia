//
//  Comments.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

struct Comments: Codable {
    @DocumentID var id: String?
    var name: String?
    var date: Date?
    var text: String?
}
