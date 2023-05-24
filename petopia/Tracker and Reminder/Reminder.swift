//
//  Reminder.swift
//  petopia
//
//  Created by Winnie Ooi on 8/5/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Reminder: Codable {
    var title: String
    var dueDate: Date
    var notes: String?
    var isComplete: Bool
}

//#if DEBUG
//extension Reminder {
//    static var sampleData = [
//    Reminder(
//    title: "Feed Amy", dueDate: Date().addingTimeInterval(800.0),
//            notes: "Don't forget to feed Amy"),
//    Reminder(
//            title: "Bring Poppy to the vet", dueDate: Date().addingTimeInterval(14000.0),
//            notes: "Poppy needs to see the vet today", isComplete: true),
//    Reminder(
//            title: "Pickup Poppy from vet", dueDate: Date().addingTimeInterval(24000.0),
//            notes: "Poppy has finished her checkup")]
//}
//
//#endif
