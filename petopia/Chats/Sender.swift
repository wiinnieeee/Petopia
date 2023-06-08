//
//  Sender.swift
//  petopia
//  Reference: https://youtube.com/playlist?list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf
//
//  Created by Winnie Ooi on 5/6/2023.
//

import Foundation
import MessageKit

// Initialisation of the sender of the message
struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}
