//
//  Reminder.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import Foundation

// Reminder created for each user
struct Reminder: Codable {
    var title: String
    var dueDate: Date
    var notes: String?
    var isComplete: Bool
}
