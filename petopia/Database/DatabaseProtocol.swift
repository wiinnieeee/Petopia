//
//  DatabaseProtocol.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import Foundation
import FirebaseAuth

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case all
    case pets
    case profile
    case reminders
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}   
    func onAllRemindersChange (change: DatabaseChange, reminders: [Reminder])

}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func registerAccount(email: String, password: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) async -> Bool
    func loginAccount(email: String, password: String) async -> Bool
    func signOutAccount()
    
    func addReminder(newReminder: Reminder?)
    func doneReminder(reminder: Reminder?)
    
    var registerSuccessful: Bool {get set}

}
