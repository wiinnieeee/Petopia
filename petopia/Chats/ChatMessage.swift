//
//  ChatMessage.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import Foundation
import MessageKit

class ChatMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
}
