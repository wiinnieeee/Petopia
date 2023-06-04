//
//  DatabaseProtocol.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import Foundation
import FirebaseAuth
import UIKit

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
    case listings
    case userlistings
    case posts
    case comments
    case postComments
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}   
    func onAllRemindersChange (change: DatabaseChange, reminders: [Reminder])
    func onAllWishlistChange (change: DatabaseChange, wishlist: [WishlistAnimal])
    func onUserChange (change: DatabaseChange, user: User)
    func onAllListingChange (change: DatabaseChange, listing: [ListingAnimal])
    func onUserListingChange (change: DatabaseChange, userListing: [ListingAnimal])
    func onAllPostsChange (change: DatabaseChange, posts: [Posts])
    func onAllCommentsChange (change: DatabaseChange, comments: [Comments])
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments] )
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
    
    func addAnimaltoWishlist(newAnimal: WishlistAnimal?, completion: @escaping (Bool) -> Void)
    func removeAnimalfromWishlist (animal: WishlistAnimal?)
    
    func deleteImage (image: String)
    
    func addAnimaltoListing (newAnimal: ListingAnimal?)
    
    func addPost (newPost: Posts?)
    func addComments(post: Posts?, newComment: Comments?)
}
