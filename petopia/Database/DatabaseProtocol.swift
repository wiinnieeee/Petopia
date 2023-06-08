//
//  DatabaseProtocol.swift
//  petopia
//  DatabaseProtocol to be followed by Firebase Controller
//  and DatabaseListeners to be followed by the View Controllers
//  To listen to the updates from the Firebase Firestore
//
//  Created by Winnie Ooi on 26/4/2023.
//

import Foundation
import FirebaseAuth
import UIKit

/// Enumeration to note down the type of change of the database to sync it together with the Firebase
enum DatabaseChange{
    case add
    case remove
    case update
}

/// Type of listeners to listen to different collections in the Firebase Firestore Database
enum ListenerType {
    case all
    case reminders
    case wishlist
    case users
    case listings
    case userlistings
    case posts
    case comments
    case conversations
}

/// Protocol to enable user to listen to the data from the Firebase based on the type of listeners and update the data accordingly
protocol DatabaseListener: AnyObject {
    // type of listeners available from the enumeration above
    var listenerType: ListenerType {get set}
    
    // listen to the reminders collection in the user in database and update
    func onAllRemindersChange (change: DatabaseChange, reminders: [Reminder])
    
    // listen to the wishlist collection in the user in database and update
    func onAllWishlistChange (change: DatabaseChange, wishlist: [WishlistAnimal])
    
    // listen to the details of the current user logged in
    func onUserChange (change: DatabaseChange, user: User)
    
    // listen to all the listings from all users that are added to the application
    func onAllListingChange (change: DatabaseChange, listing: [ListingAnimal])
    
    // listen to the listings created by each user specifically
    func onUserListingChange (change: DatabaseChange, userListing: [ListingAnimal])
    
    // listen to all the posts created from all users that are added to the application
    func onAllPostsChange (change: DatabaseChange, posts: [Posts])
    
    // listen to all the comments on a specific posts made by all users of the application
    func onAllCommentsChange (change: DatabaseChange, comments: [Comments])
    
    // listen to all conversations that a user has with the other users in the application
    func onAllConversationsChange (change: DatabaseChange, conversations: [Conversation])
}

/// Database protocol followed by the Firebase Controller to listen to updates based on listeners from the Firestore
protocol DatabaseProtocol: AnyObject {
    // Save data from the AppDelegate
    func cleanup()
    
    // Used to add and remove listeners to the view controller based on the listener declared
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // MARK: Authenciation
    // Methods associated to update database during registration/login/logout
    func registerAccount(email: String, password: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) async -> Bool
    func loginAccount(email: String, password: String) async -> Bool
    func signOutAccount()
    var registerSuccessful: Bool {get set}
    
    // MARK: Reminders
    // Methods associated to adding/removing/updating Reminders for each user
    func addReminder(newReminder: Reminder?)
    func doneReminder(reminder: Reminder?)
    func deleteReminder (reminder: Reminder?)
    
    // MARK: Wishlists
    // Methods associated to adding/removing pets from wishlist for each user
    func addAnimaltoWishlist(newAnimal: WishlistAnimal?, completion: @escaping (Bool) -> Void)
    func removeAnimalfromWishlist (animal: WishlistAnimal?)
    
    func deleteImage (image: String)
    
    // MARK: Listings
    // Methods associated to create listing for the user
    func addAnimaltoListing (newAnimal: ListingAnimal?)
    
    // MARK: Community
    // Methods associated to create new posts and create comments for posts
    func addPost (newPost: Posts?)
    func addComments(post: Posts?, newComment: Comments?)
    
    // MARK: Chat Messaging
    // Methods associated for the user to engage with other users by chatting with each other
    func createNewConversation (pet: String?, ownName: String?, otherName: String?, otherUserID: String?, firstMessage: Message, completion: @escaping (Bool) -> Void) -> String?
    func sendMessage(otherUserID: String?, conversation:String?, name: String?, message: Message, completion: @escaping (Bool) -> Void)
}
