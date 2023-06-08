//
//  Conversation.swift
//  petopia
//  Reference: https://youtube.com/playlist?list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf
//
//  Created by Winnie Ooi on 5/6/2023.
//

import Foundation
import FirebaseFirestoreSwift

/// Conversation created by each user when the first message is sent
struct Conversation: Codable {
    @DocumentID var id: String?
    var otherUserID: String?
    var latestIsRead: Bool?
    var latestDate: String?
    var latestMessage: String?
    var name: String?
    var pet: String?
}
