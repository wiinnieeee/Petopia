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
    case reminders
    case wishlist
    case users
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}   
    func onAllRemindersChange (change: DatabaseChange, reminders: [Reminder])
    func onAllWishlistChange (change: DatabaseChange, wishlist: [Int])
    func onUserChange (change: DatabaseChange, user: User)

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
    func deleteReminder (reminder: Reminder?)
    
    var registerSuccessful: Bool {get set}
    
    func addAnimaltoWishlist(newAnimal: Animal?)
    func removeAnimalfromWishlist (animal: Animal?)
    

}
