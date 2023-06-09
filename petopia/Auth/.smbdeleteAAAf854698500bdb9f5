//
//  FirebaseController.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var authController: Auth
    var database: Firestore
    
    // MARK: Collection References and Update List
    var remindersRef: CollectionReference?
    var reminderList : [Reminder]
    
    var usersRef: CollectionReference?
    var currentUser: User?
    
    var wishlistRef: CollectionReference?
    var wishlistList: [WishlistAnimal]
    
    var listingRef: CollectionReference?
    var listingList: [ListingAnimal]
    
    var postsRef: CollectionReference?
    var postsList: [Posts]
    var currentPost: Posts?
    
    var commentsRef: CollectionReference?
    var commentsList: [Comments]
    
    var userConversationRef: CollectionReference?
    var recipientConversationRef: CollectionReference?
    
    var conversationRef: CollectionReference?
    var messagesRef: CollectionReference?
    
    var conversationList: [Conversation]
    var messagesList: [Message]
    
    // Check if registration is successful
    var registerSuccessful: Bool = false
    
    override init(){
        // Configure the Firebase
        FirebaseApp.configure()
        
        // Assign Firebase variables and initialise them after declaration
        authController = Auth.auth()
        database = Firestore.firestore()
        reminderList = [Reminder]()
        wishlistList = [WishlistAnimal]()
        listingList = [ListingAnimal]()
        postsList = [Posts]()
        commentsList = [Comments]()
        conversationList = [Conversation]()
        messagesList = [Message]()
        
        // Initialise collection references
        usersRef = database.collection("users")
        listingRef = database.collection("listings")
        postsRef = database.collection("posts")
        
        super.init()
        
        // If there is a user logged in, setup listeners and initialise collection references based on userID
        if authController.currentUser != nil{
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            wishlistRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("wishlist")
            self.setupRemindersListener()
            self.setupWishlistListener()
            self.setupListingListener()
            self.setupUserListener()
            self.setupPostListener()
            self.setupConversationsListener()
        }
    }
    
    func cleanup() {
        // do nothing
    }
    
    /// Function to add listeners and update the database change
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        if listener.listenerType == .reminders || listener.listenerType == .all {
            listener.onAllRemindersChange(change: .update, reminders: reminderList)
        }
        if listener.listenerType == .wishlist || listener.listenerType == .all {
            listener.onAllWishlistChange (change: .update, wishlist: wishlistList)
        }
        if listener.listenerType == .users || listener.listenerType == .all {
            listener.onUserChange(change: .update, user: currentUser!)
        }
        if listener.listenerType == .listings || listener.listenerType == .all {
            listener.onAllListingChange(change: .update, listing: listingList)
        }
        if listener.listenerType == .userlistings ||  listener.listenerType == .all {
            listener.onUserListingChange(change: .update, userListing: currentUser!.listingList)
        }
        if listener.listenerType == .posts || listener.listenerType == .all {
            listener.onAllPostsChange(change: .update, posts: postsList)
        }
        if listener.listenerType == .comments || listener.listenerType == ListenerType.all {
            listener.onAllCommentsChange(change: .update, comments: commentsList)
        }
        if listener.listenerType == ListenerType.conversations || listener.listenerType == ListenerType.all {
            listener.onAllConversationsChange(change: .update, conversations: conversationList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /// Register account for user using the details input, record user in Firestore and Authenciation
    func registerAccount(email: String, password: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) async -> Bool {
        
        var isSuccessful = false
        
        do
        { _ = try await authController.createUser(withEmail: email, password: password)
            
            // Add user to database
            self.addUser(emailAdd: email, name: name, phoneNumber: phoneNumber, streetAdd: streetAdd, postCode: postCode, suburb: suburb, country: country)
            isSuccessful = true
            
            // Set user defaults for email
            UserDefaults.standard.set(email, forKey: "email")
            
            // Create collection reference once successful registration and setup listeners
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            wishlistRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("wishlist")
            self.setupRemindersListener()
            self.setupWishlistListener()
            self.setupListingListener()
            self.setupUserListener()
            self.setupPostListener()
            self.setupConversationsListener()
            
        } catch {
            print ("User creation failed with error: \(String(describing: error))")
            return false
        }
        return isSuccessful
    }
    
    /// Login Action for the user using email and password
    func loginAccount(email: String, password: String) async ->  Bool {
        var isSuccessful = false
        
        do
        {   _ = try await authController.signIn(withEmail: email, password: password)
            isSuccessful = true
            
            // Set user defaults for email
            UserDefaults.standard.set(email, forKey: "email")
            
            // Create collection reference once successful login and setup listeners
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            wishlistRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("wishlist")
            self.setupRemindersListener()
            self.setupWishlistListener()
            self.setupListingListener()
            self.setupUserListener()
            self.setupPostListener()
            self.setupConversationsListener()
            
        }
        catch {
            print ("Authenciation failed with error: \(String(describing: error))")
            return false
        }
        return isSuccessful
    }
    
    /// Sign out of the user account
    func signOutAccount() {
        do {
            // Clear all the data inside when sign out for listeners to listen and retrieve new data
            wishlistList = []
            reminderList = []
            listingList = []
            postsList = []
            commentsList = []
            conversationList =  []
            try authController.signOut()
        }
        catch {
            print(error)
        }
    }
    
    /// Add the user into the Firebase Firestore Collection
    func addUser(emailAdd: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) {
        // Document ID be the user authenciation uid
        let documentID = authController.currentUser!.uid
        let data = ["emailAdd": emailAdd, "name": name, "phoneNumber": phoneNumber, "streetAdd": streetAdd, "postcode": postCode, "suburb": suburb, "country": country] as [String : Any]
        database.collection("users").document(documentID).setData(data as [String: Any])
    }
    
    /// Add reminder for the specific user into the Firebase Firestore
    func addReminder(newReminder: Reminder? ) {
        let title = newReminder?.title
        let notes = newReminder?.notes
        let dueDate = newReminder?.dueDate
        let isComplete = newReminder?.isComplete
        
        let data = ["title": title!, "notes" : notes!, "dueDate": dueDate!, "isComplete": isComplete!] as [String : Any]
        remindersRef!.addDocument(data: data)
    }
    
    /// Update the reminder in the Firebase Firestore when a reminder is done
    func doneReminder(reminder: Reminder?) {
        let documentID = authController.currentUser!.uid
        let remindersRef = database.collection("users").document("\(documentID)").collection("reminders")
        // Query for the reminder in the collection using the title
        remindersRef.whereField("title", isEqualTo: (reminder?.title)!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // Update reminder to complete in the Firestore when user completes it
                    document.reference.updateData(["isComplete": true])
                }
            }
        }
    }
    
    /// Delete the reminder in the Firebase Firestore
    func deleteReminder(reminder: Reminder?) {
        // Query for the reminder in the collection using the title
        remindersRef!.whereField("title", isEqualTo: (reminder?.title)!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    /// Add the pet to wishlist of the user
    func addAnimaltoWishlist(newAnimal: WishlistAnimal?, completion: @escaping (Bool) -> Void) {
        let name = newAnimal?.name
        let age = newAnimal?.age
        let breed = newAnimal?.breed
        let description = newAnimal?.description
        let gender = newAnimal?.gender
        let phoneNumber = newAnimal?.phoneNumber
        let emailAddress = newAnimal?.emailAddress
        let type = newAnimal?.type
        let imageID = newAnimal?.imageID ?? ""
        let imageURL = newAnimal?.imageURL ?? ""
        let ownerID = newAnimal?.ownerID ?? ""
        
        
        let data = ["name": name!, "age": age!, "breed": breed!, "description": description!,
                    "gender": gender!, "phoneNumber": phoneNumber!, "emailAddress": emailAddress, "type": type!, "imageID": imageID, "imageURL": imageURL, "ownerID": ownerID]
        
        // Query the wishlist if there is existing document of the same newAnimal data
        // To prevent duplicates
        let query = wishlistRef!.whereField("name", isEqualTo: name!)
            .whereField("age", isEqualTo: age!)
            .whereField("breed", isEqualTo: breed!)
            .whereField("description", isEqualTo: description!)
            .whereField("phoneNumber", isEqualTo: phoneNumber!)
            .whereField("emailAddress", isEqualTo: emailAddress!)
            .whereField("type", isEqualTo: type!)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                // Handle the error
                print("Error checking for duplicates: \(error)")
                return
            }
            
            guard let snapshot = snapshot else {
                // Handle the case where the snapshot is nil
                return
            }
            
            // Check if there is documents
            // If yes, meaning there is duplicate
            if snapshot.documents.isEmpty {
                // No duplicate found, add the entry, return completion to be false
                self.wishlistRef!.addDocument(data: data as [String : Any])
                completion(false)
            } else {
                // Print duplicate entry found, return completion to be true
                print("Duplicate entry found")
                completion(true)
            }
        }
    }
    
    /// Remove the animal from the wishlist
    func removeAnimalfromWishlist (animal: WishlistAnimal?) {
        // Query for the name of the pet to find the animal to be removed in the collection
        wishlistRef!.whereField("name", isEqualTo: (animal?.name)!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // Delete the document if found
                    document.reference.delete()
                }
            }
        }
    }
    
    /// Create new listing and add the animal to the listing collection of the user and the listing collections overall
    func addAnimaltoListing(newAnimal: ListingAnimal?) {
        let listing = ListingAnimal()
        listing.name = newAnimal?.name
        listing.age = newAnimal?.age
        listing.breed = newAnimal?.breed
        listing.desc = newAnimal?.desc
        listing.gender = newAnimal?.gender
        listing.phoneNumber = newAnimal?.phoneNumber
        listing.emailAddress = newAnimal?.emailAddress
        listing.type = newAnimal?.type
        listing.ownerID = newAnimal?.ownerID
        listing.imageID = newAnimal?.imageID
        
        do {
            // Add listing to the listing collections overall which stores all listings
            if let listRef = try listingRef?.addDocument(from: listing){
                listing.id = listRef.documentID
                // Add listing to the user's own listing collections by using reference
                usersRef?.document((Auth.auth().currentUser?.uid)!).updateData(["listing": FieldValue.arrayUnion([listRef])])
            }
            
        } catch {
            print("failed to serialize listing")
        }
        
        
    }
    
    /// Delete image from gallery collection view
    func deleteImage(image: String) {
        let imagesRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("images")
        imagesRef.document("\(image)").delete()
    }
    
    /// Add a new post to the total collection of posts
    func addPost(newPost: Posts?) {
        postsRef = database.collection("posts")
        let title = newPost?.title
        let content = newPost?.content
        let date = newPost?.date
        let userName = newPost?.name
        
        let data = ["title": title!, "content": content!, "date": date!, "name": userName!] as [String : Any]
        
        // Initialise the post and add the document
        var post = Posts(name: userName, date: date, title: title, content: content)
        
        if let postRef =  postsRef?.addDocument(data: data){
            post.id = postRef.documentID
        }
        
        
    }
    
    /// Add comments to the specific post
    func addComments(post: Posts?, newComment: Comments?) {
        let content = newComment?.text
        let userName = newComment?.name
        let date = newComment?.date
        
        var comment = Comments(name: userName!, date: date!, text: content!)
        
        // Initialise the comments collection
        commentsRef = database.collection("posts").document((post?.id!)!).collection("comments")
        
        do {
            if let commentRef = try commentsRef?.addDocument(from: comment){
                comment.id = commentRef.documentID
            }
        } catch {
            print("failed to serialize comment")
        }
    }
    
    ///Setup to listen to user's reminders from the collection reference
    func setupRemindersListener() {
        remindersRef!.addSnapshotListener() {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // if valid, we call the parseRemindersSnapshot to handle parsing changes made on Firestore
            self.parseRemindersSnapshot(snapshot: querySnapshot)
        }
    }
    
    ///Setup to listen to user's wishlists from the collection reference
    func setupWishlistListener() {
        wishlistRef!.addSnapshotListener() {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // if valid, we call the parseWishlistSnapshot to handle parsing changes made on Firestore
            self.parseWishlistSnapshot(snapshot: querySnapshot)
        }
    }
    
    ///Setup to listen to user's wishlists from the collection reference
    func setupUserListener() {
        // Use the user's email to listen for the user details
        if let userEmail = Auth.auth().currentUser?.email {
            self.usersRef!.whereField("emailAdd", isEqualTo: userEmail).addSnapshotListener(){
                (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot, let wishlistSnapshot = querySnapshot.documents.first else {
                    print ("Failed to fetch users with error: \(String(describing: error))")
                    return
                }
                
                // if valid, we call the parseUserSnapshot to handle parsing changes made on Firestore
                self.parseUserSnapshot(snapshot: wishlistSnapshot)
            }
        }
    }
    
    ///Setup to listen to listings from the collection reference
    func setupListingListener() {
        listingRef = database.collection("listings")
        listingRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // if valid, we call the parseListingSnapshot to handle parsing changes made on Firestore
            self.parseListingSnapshot(snapshot: querySnapshot)
            
        }
    }
    
    ///Setup to listen to posts from the collection reference
    func setupPostListener() {
        postsRef?.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            // if valid, we call the parsePostsSnapshot to handle parsing changes made on Firestore
            self.parsePostsSnapshot(snapshot: querySnapshot)
        }
    }
    
    ///Parse and decode the reminder changes made on the Firestore
    func parseRemindersSnapshot (snapshot: QuerySnapshot){
        // create for-each loop togo through each document change in snapshot
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedReminder: Reminder?
            
            do {
                // done using Codable - do catch statement
                parsedReminder = try change.document.data(as: Reminder.self)
            } catch {
                print ("Unable to decode reminder.")
                return
            }
            
            // make sure parsedReminder isn't nil
            guard let reminder = parsedReminder else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
            if change.type == .added {
                reminderList.insert(reminder, at: Int(change.newIndex))
            } else if change.type == .modified {
                reminderList [Int (change.oldIndex)] = reminder
            } else if change.type == .removed {
                reminderList.remove(at: Int(change.oldIndex))
            }
            
            // Invoke listener to update the reminders
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.reminders || listener.listenerType == ListenerType.all {
                    listener.onAllRemindersChange(change: .update, reminders: reminderList)
                }
            }
        }
    }
    
    ///Parse and decode the specific user on the Firestore
    func parseUserSnapshot (snapshot: QueryDocumentSnapshot){
        currentUser = User()
        currentUser?.name = snapshot.data()["name"] as? String
        currentUser?.email = snapshot.data()["emailAdd"] as? String
        currentUser?.phoneNumber = snapshot.data()["phoneNumber"] as? String
        currentUser?.address = snapshot.data()["streetAdd"] as? String
        
        
        if let listingReferences = snapshot.data()["listing"] as? [DocumentReference] {
            for reference in listingReferences {
                // loop through each reference
                // get document ID and getListingbyID method to get listing and add it to the listingList
                if let listing = getListingByID(reference.documentID) {
                    currentUser?.listingList.append(listing)
                }
            }
            
            // Invoke listeners
            // Can listen to the user details or the listings of the user
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.users || listener.listenerType == ListenerType.all {
                    listener.onUserChange (change: .update, user: currentUser!)
                }
                if listener.listenerType == ListenerType.userlistings || listener.listenerType == ListenerType.all {
                    listener.onUserListingChange(change: .update, userListing: currentUser!.listingList)
                }
            }
        }
    }
    
    /// Obtain the listing instance through the id of the listing
    func getListingByID (_ id: String) -> ListingAnimal? {
        for listing in listingList {
            if listing.id == id {
                return listing
            }
        }
        return nil
    }
    
    /// Obtain the comments instance through the id of the listing
    func getCommentsByID (_ id: String) -> Comments? {
        for comment in commentsList {
            if comment.id == id {
                return comment
            }
        }
        return nil
    }
    
    ///Parse and decode the wishlist of the user on the Firestore
    func parseWishlistSnapshot (snapshot: QuerySnapshot){
        // create for-each loop togo through each document change in snapshot
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedwishlistAnimal: WishlistAnimal?
            
            do {
                // done using Codable - do catch statement
                parsedwishlistAnimal = try change.document.data(as: WishlistAnimal.self)
            } catch {
                print ("Unable to decode wishlist.")
                return
            }
            
            // make sure parsedwishlistAnimal isn't nil
            guard let wishlistAnimal = parsedwishlistAnimal else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
            if change.type == .added {
                wishlistList.insert(wishlistAnimal, at: Int(change.newIndex))
            } else if change.type == .modified {
                wishlistList [Int (change.oldIndex)] = wishlistAnimal
            } else if change.type == .removed {
                wishlistList.remove(at: Int(change.oldIndex))
            }
            
            // Invoke listeners to update the wishlist Animals
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.wishlist || listener.listenerType == ListenerType.all {
                    listener.onAllWishlistChange (change: .update, wishlist: wishlistList)
                }
            }
        }
    }
    
    /// Parse and decode the all the listings on the Firestore
    func parseListingSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedlistingAnimal: ListingAnimal?
            
            do {
                // done using Codable - do catch statement
                parsedlistingAnimal = try change.document.data(as: ListingAnimal.self)
            } catch {
                print ("Unable to decode listing.")
                return
            }
            
            // make sure parsedlistingAnimal isn't nil
            guard let listingAnimal = parsedlistingAnimal else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
            if change.type == .added {
                listingList.insert(listingAnimal, at: Int(change.newIndex))
            } else if change.type == .modified {
                listingList [Int (change.oldIndex)] = listingAnimal
            } else if change.type == .removed {
                listingList.remove(at: Int(change.oldIndex))
            }
            
            // Invoke listeners to update the listing list overall
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.listings || listener.listenerType == ListenerType.all {
                    listener.onAllListingChange(change: .update, listing: listingList)
                }
            }
        }
    }
    
    /// Parse and decode all the posts on the Firestore
    func parsePostsSnapshot (snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedPosts: Posts?
            
            do {
                // done using Codable - do catch statement
                parsedPosts = try change.document.data(as: Posts.self)
            } catch {
                print ("Unable to decode listing.")
                return
            }
            
            // make sure parsedPosts isn't nil
            guard let post = parsedPosts else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
            if change.type == .added {
                postsList.insert(post, at: Int(change.newIndex))
            } else if change.type == .modified {
                postsList [Int (change.oldIndex)] = post
            } else if change.type == .removed {
                postsList.remove(at: Int(change.oldIndex))
            }
            
            // Invoke listeners to update the posts
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.posts || listener.listenerType == ListenerType.all {
                    listener.onAllPostsChange(change: .update, posts: postsList)
                }
            }
        }
    }
    
    // MARK: - Sending Messages / Conversations
    /// Creates a new conversation with target user id and the first message sent
    func createNewConversation (pet: String?, ownName: String?, otherName: String?, otherUserID: String?, firstMessage: Message, completion: @escaping (Bool) -> Void) -> String? {
        // Get the current user ID
        guard let currentID = Auth.auth().currentUser?.uid else {
            completion(false)
            return nil
        }
        
        // Get the latest date in a string
        let latestDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: latestDate)
        var message = ""
        
        // Obtain the message string based on the firstMessage
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        // Access the conversations collection for both the current user and the recipient
        userConversationRef = database.collection("users").document(currentID).collection("conversations")
        recipientConversationRef = database.collection("users").document(otherUserID!).collection("conversations")
        
        // First message from the user used to create a conversation instance
        let userData = ["otherUserID": otherUserID!, "latestIsRead": false, "latestDate": dateString, "latestMessage": message, "name": otherName!, "pet": pet!] as [String : Any]
        let recipientData = ["otherUserID": currentID, "latestIsRead": false, "latestDate": dateString, "latestMessage": message, "name": ownName!, "pet": pet!] as [String : Any]
        
        // Create conversation using first message from the user
        var userNewConvo = Conversation(otherUserID: otherUserID, latestIsRead: false, latestDate: dateString, latestMessage: message, name: otherName, pet : pet!)
        var recipientNewConvo = Conversation(otherUserID: currentID, latestIsRead: false, latestDate: dateString, latestMessage: message, name: ownName!, pet : pet!)
        
        // Add the document to both user and recipient conversation collection with the same conversation ID
        if let userConvoRef =  userConversationRef?.addDocument(data: userData){
            userNewConvo.id = userConvoRef.documentID
            recipientNewConvo.id = userConvoRef.documentID
            
            // Use the same conversationID to add document for recipient
            recipientConversationRef?.document("\(userConvoRef.documentID)").setData(recipientData)
            
            // When finish creating conversation, need to record the conversation in the overall collection as well
            self.finishCreatingConversation(pet: pet!, name: otherName!, conversationID: userConvoRef.documentID, firstMessage: firstMessage, completion: completion)
            completion(true)
            return userConvoRef.documentID
        }
        return nil
    }
    
    /// Method to record the first message in the conversations collections so in the future can append more messages
    func finishCreatingConversation (pet: String?, name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        // Create a new collection reference for conversations
        conversationRef = database.collection("conversations")
        
        // Record details of the conversation
        // Which is the animal and the contact user
        conversationRef?.document("\(conversationID)").setData(["id": conversationID, "animal": pet!, "contactUser": (Auth.auth().currentUser?.uid)!])
        
        // Refer to the messages collection which stores all messages for the collection
        let convoRef = conversationRef?.document("\(conversationID)")
        messagesRef = convoRef?.collection("messages")
        
        // Obtain date in string
        let latestDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: latestDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        // Add the first message inside the message collection of the conversation
        let data = ["name": name, "id": firstMessage.messageId, "type": firstMessage.kind.messageKindString, "content": message, "date": dateString, "sender_id": (Auth.auth().currentUser?.uid)!, "isRead": false ] as [String : Any]
        
        if let _ = messagesRef?.addDocument(data: data) {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    /// Listen to update all the conversations by the user
    func setupConversationsListener(){
        conversationRef = database.collection("users").document("\((Auth.auth().currentUser?.uid)!)").collection("conversations")
        conversationRef?.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // Parse the conversations
            self.parseConversationsSnapshot(snapshot: querySnapshot)
        }
    }
    
    /// Parse and decode all the conversations of the on the Firestore
    func parseConversationsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedConversations: Conversation?
            
            do {
                // done using Codable - do catch statement
                parsedConversations = try change.document.data(as: Conversation.self)
            } catch {
                print ("Unable to decode conversations.")
                return
            }
            
            // make sure parsedConversation isn't nil
            guard let convo = parsedConversations else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
            if change.type == .added {
                conversationList.insert(convo, at: Int(change.newIndex))
            } else if change.type == .modified {
                conversationList [Int (change.oldIndex)] = convo
            } else if change.type == .removed {
                conversationList.remove(at: Int(change.oldIndex))
            }
            
            // Invoke the listeners for all the conversations for the user
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.conversations || listener.listenerType == ListenerType.all {
                    listener.onAllConversationsChange(change: .update, conversations: conversationList)
                }
            }
        }
        
    }
    
    /// Send message with a message for an existing conversation
    func sendMessage(otherUserID: String?, conversation: String?, name: String?, message: Message, completion: @escaping (Bool) -> Void) {
        // add new message to message collection of the conversation
        messagesRef = database.collection("conversations").document("\(conversation!)").collection("messages")
        
        let latestDate = message.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: latestDate)
        var newMessage = ""
        
        
        switch message.kind {
        case .text(let messageText):
            newMessage = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let data = ["name": name!, "id": message.messageId, "type": message.kind.messageKindString, "content": newMessage, "date": dateString, "sender_id": (Auth.auth().currentUser?.uid)!, "isRead": false ] as [String : Any]
        
        // Add message to the messages collections of the specific conversation of the user
        if let _ = messagesRef?.addDocument(data: data) {
            
            guard let currentID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            // Update the latest message to be shown for the user and recipient conversation collection
            userConversationRef = database.collection("users").document("\(currentID)").collection("conversations")
            recipientConversationRef = database.collection("users").document("\(otherUserID!)").collection("conversations")
            let data = ["latestMessage": newMessage, "latestDate": dateString, "isRead": false] as [String : Any]
            userConversationRef?.document("\(conversation!)").updateData(data)
            recipientConversationRef?.document("\(conversation!)").updateData(data)
            
            completion(true)
        } else {
            completion(false)
        }
    }
}
