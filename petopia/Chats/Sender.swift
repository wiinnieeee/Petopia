//
//  Sender.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import Foundation
import UIKit
import MessageKit

class Sender: SenderType {
    var senderId: String
    var photoURL: String
    var displayName: String
    
    init(senderId: String, photoURL: String, displayName: String) {
        self.senderId = senderId
        self.photoURL = photoURL
        self.displayName = displayName
    }
}
