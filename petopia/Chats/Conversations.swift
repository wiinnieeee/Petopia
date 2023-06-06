//
//  Conversation.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Conversation: Codable {
    @DocumentID var id: String?
    var otherUserID: String?
    var latestIsRead: Bool?
    var latestDate: String?
    var latestMessage: String?
    var name: String?
    var pet: String?
}
