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
    
    var registerSuccessful: Bool = false
    
    override init(){
        FirebaseApp.configure()
        
        // assign Firebase var
        authController = Auth.auth()
        database = Firestore.firestore()
        reminderList = [Reminder]()
        wishlistList = [WishlistAnimal]()
        listingList = [ListingAnimal]()
        postsList = [Posts]()
        commentsList = [Comments]()
        conversationList = [Conversation]()
        messagesList = [Message]()
        
        usersRef = database.collection("users")
        listingRef = database.collection("listings")
        postsRef = database.collection("posts")
        
        super.init()
        
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
        if listener.listenerType == .postComments || listener.listenerType == ListenerType.all {
            listener.onPostCommentsChange(change: .update, postComments: (currentPost?.comments)!)
        }
        if listener.listenerType == ListenerType.conversations || listener.listenerType == ListenerType.all {
            listener.onAllConversationsChange(change: .update, conversations: conversationList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func registerAccount(email: String, password: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) async -> Bool {
        
        var isSuccessful = false
        
        do
        { _ = try await authController.createUser(withEmail: email, password: password)
            
            self.addUser(emailAdd: email, name: name, phoneNumber: phoneNumber, streetAdd: streetAdd, postCode: postCode, suburb: suburb, country: country)
            isSuccessful = true
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(name, forKey: "username")
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
    
    func loginAccount(email: String, password: String) async ->  Bool {
        var isSuccessful = false
        
        do
        {   _ = try await authController.signIn(withEmail: email, password: password)
            isSuccessful = true
            UserDefaults.standard.set(email, forKey: "email")
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            wishlistRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("wishlist")
            //commentsRef = database.collection("posts").document((currentPost?.id)!).collection("comments")
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
    
    func signOutAccount() {
        do {
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
    
    
    func addUser(emailAdd: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) {
        let documentID = authController.currentUser!.uid
        let data = ["emailAdd": emailAdd, "name": name, "phoneNumber": phoneNumber, "streetAdd": streetAdd, "postcode": postCode, "suburb": suburb, "country": country] as [String : Any]
        database.collection("users").document(documentID).setData(data as [String: Any])
    }
    
    func addReminder(newReminder: Reminder? ) {
        let title = newReminder?.title
        let notes = newReminder?.notes
        let dueDate = newReminder?.dueDate
        let isComplete = newReminder?.isComplete
        
        let data = ["title": title!, "notes" : notes!, "dueDate": dueDate!, "isComplete": isComplete!] as [String : Any]
        remindersRef!.addDocument(data: data)
    }
    
    func doneReminder(reminder: Reminder?) {
        let documentID = authController.currentUser!.uid
        let remindersRef = database.collection("users").document("\(documentID)").collection("reminders")
        remindersRef.whereField("title", isEqualTo: (reminder?.title)!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData(["isComplete": true])
                }
            }
        }
    }
    
    func deleteReminder(reminder: Reminder?) {
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
            
            if snapshot.documents.isEmpty {
                // No duplicate found, add the entry
                self.wishlistRef!.addDocument(data: data as [String : Any])
                completion(false)
            } else {
                print("Duplicate entry found")
                completion(true)
            }
        }
    }
    
    
    func removeAnimalfromWishlist (animal: WishlistAnimal?) {
        wishlistRef!.whereField("name", isEqualTo: (animal?.name)!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
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
            if let listRef = try listingRef?.addDocument(from: listing){
                listing.id = listRef.documentID
                usersRef?.document((Auth.auth().currentUser?.uid)!).updateData(["listing": FieldValue.arrayUnion([listRef])])
            }
            
        } catch {
            print("failed to serialize listing")
        }
        
        
    }
    
    func deleteImage(image: String) {
        let imagesRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("images")
        imagesRef.document("\(image)").delete()
    }
    
    func addPost(newPost: Posts?) {
        postsRef = database.collection("posts")
        let title = newPost?.title
        let content = newPost?.content
        let date = newPost?.date
        let userName = newPost?.name
       
        let data = ["title": title!, "content": content!, "date": date!, "name": userName!] as [String : Any]
        
        var post = Posts(name: userName, date: date, title: title, content: content)
        
        if let postRef =  postsRef?.addDocument(data: data){
            //get the document ID and store it within the team instance.
            post.id = postRef.documentID
        }
        
        
    }
    
    func addComments(post: Posts?, newComment: Comments?) {
        let content = newComment?.text
        let userName = newComment?.name
        let date = newComment?.date
        
        var comment = Comments(name: userName!, date: date!, text: content!)
        
        commentsRef = database.collection("posts").document((post?.id!)!).collection("comments")
        
        do {
            if let commentRef = try commentsRef?.addDocument(from: comment){
                comment.id = commentRef.documentID
            }
        } catch {
            print("failed to serialize comment")
        }
    }
    
    
    func setupRemindersListener() {
        remindersRef!.addSnapshotListener() {
            (querySnapshot, error) in
            
            // inside closure, ensure snapshot valid but not just a nil value
            // if nil, need to return immediately
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // if valid, we call the parseRemindersSnapshot to handle parsing changes made on Firestore
            self.parseRemindersSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupWishlistListener() {
        wishlistRef!.addSnapshotListener() {
            (querySnapshot, error) in
            
            // inside closure, ensure snapshot valid but not just a nil value
            // if nil, need to return immediately
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // if valid, we call the parseRemindersSnapshot to handle parsing changes made on Firestore
            self.parseWishlistSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupUserListener() {
        if let userEmail = Auth.auth().currentUser?.email {
            self.usersRef!.whereField("emailAdd", isEqualTo: userEmail).addSnapshotListener(){
                (querySnapshot, error) in
                
                // closure executed asynchroously at some later point, continue to execute every single time a change detected on Superheroes collection
                // inside closure, ensure snapshot valid but not just a nil value
                // if nil, need to return immediately
                
                guard let querySnapshot = querySnapshot, let wishlistSnapshot = querySnapshot.documents.first else {
                    print ("Failed to fetch users with error: \(String(describing: error))")
                    return
                }
                
                // if valid, we call the parseHeroesSnapshot to handle parsing changes made on Firestore
                self.parseUserSnapshot(snapshot: wishlistSnapshot)
            }
        }
    }
    
    func setupListingListener() {
        listingRef = database.collection("listings")
        listingRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseListingSnapshot(snapshot: querySnapshot)
            
        }
    }
    
    func setupPostListener() {
        postsRef?.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parsePostsSnapshot(snapshot: querySnapshot)
        }
    }
    
    
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
            
            // make sure parsedHero isn't nil
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
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.reminders || listener.listenerType == ListenerType.all {
                    listener.onAllRemindersChange(change: .update, reminders: reminderList)
                }
            }
        }
    }
    
    func parseUserSnapshot (snapshot: QueryDocumentSnapshot){
        currentUser = User()
        currentUser?.name = snapshot.data()["name"] as? String
        currentUser?.email = snapshot.data()["emailAdd"] as? String
        currentUser?.phoneNumber = snapshot.data()["phoneNumber"] as? String
        currentUser?.address = snapshot.data()["streetAdd"] as? String
        
        
        if let listingReferences = snapshot.data()["listing"] as? [DocumentReference] {
            for reference in listingReferences {
                // loop through each reference
                // get document ID and getHerobyID method to get hero and add it into the team
                print(reference.documentID)
                if let listing = getListingByID(reference.documentID) {
                    currentUser?.listingList.append(listing)
                }
            }
            
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
    
    func getListingByID (_ id: String) -> ListingAnimal? {
        for listing in listingList {
            if listing.id == id {
                return listing
            }
        }
        return nil
    }
    
    func getCommentsByID (_ id: String) -> Comments? {
        for comment in commentsList {
            if comment.id == id {
                return comment
            }
        }
        return nil
    }
    
    
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
            
            // make sure parsedHero isn't nil
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
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.wishlist || listener.listenerType == ListenerType.all {
                    listener.onAllWishlistChange (change: .update, wishlist: wishlistList)
                }
            }
        }
    }
    
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
            
            // make sure parsedHero isn't nil
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
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.listings || listener.listenerType == ListenerType.all {
                    listener.onAllListingChange(change: .update, listing: listingList)
                }
            }
        }
    }
    
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
            
            // make sure parsedHero isn't nil
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
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.posts || listener.listenerType == ListenerType.all {
                    listener.onAllPostsChange(change: .update, posts: postsList)
                }
            }
        }
    }
    
// MARK: - Sending Messages / Conversations
    
    /// creates a new conversation with target user id and the first message sent
    func createNewConversation (pet: String?, ownName: String?, otherName: String?, otherUserID: String?, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
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
        
        userConversationRef = database.collection("users").document(currentID).collection("conversations")
        recipientConversationRef = database.collection("users").document(otherUserID!).collection("conversations")
        let userData = ["otherUserID": otherUserID!, "latestIsRead": false, "latestDate": dateString, "latestMessage": message, "name": otherName!, "pet": pet!] as [String : Any]
        let recipientData = ["otherUserID": currentID, "latestIsRead": false, "latestDate": dateString, "latestMessage": message, "name": ownName!, "pet": pet!] as [String : Any]
        
        var userNewConvo = Conversation(otherUserID: otherUserID, latestIsRead: false, latestDate: dateString, latestMessage: message, name: otherName, pet : pet!)
        var recipientNewConvo = Conversation(otherUserID: currentID, latestIsRead: false, latestDate: dateString, latestMessage: message, name: ownName!, pet : pet!)
        
        if let userConvoRef =  userConversationRef?.addDocument(data: userData){
            //get the document ID and store it within the team instance.
            userNewConvo.id = userConvoRef.documentID
            recipientConversationRef?.document("\(userConvoRef.documentID)").setData(recipientData)
            recipientNewConvo.id = userConvoRef.documentID
            self.finishCreatingConversation(pet: pet!, name: otherName! ,conversationID: userConvoRef.documentID, firstMessage: firstMessage, completion: completion)
            completion(true)
        }
    }
    
    func finishCreatingConversation (pet: String?, name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        conversationRef = database.collection("conversations")
        conversationRef?.document("\(conversationID)").setData(["id": conversationID, "animal": pet!])
        let convoRef = conversationRef?.document("\(conversationID)")
        messagesRef = convoRef?.collection("messages")
        
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
        
        let data = ["name": name, "id": firstMessage.messageId, "type": firstMessage.kind.messageKindString, "content": message, "date": dateString, "sender_id": (Auth.auth().currentUser?.uid)!, "isRead": false ] as [String : Any]
        
        if let _ = messagesRef?.addDocument(data: data) {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func setupConversationsListener(){
        conversationRef = database.collection("users").document("\((Auth.auth().currentUser?.uid)!)").collection("conversations")
        conversationRef?.addSnapshotListener(){
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseConversationsSnapshot(snapshot: querySnapshot)
        }
    }
    
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
            
            // make sure parsedHero isn't nil
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
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.conversations || listener.listenerType == ListenerType.all {
                    listener.onAllConversationsChange(change: .update, conversations: conversationList)
                }
            }
        }

    }
     
    /// Send message with a message for a conversation
    func sendMessage(otherUserID: String?, conversation: String?, name: String?, message: Message, completion: @escaping (Bool) -> Void) {
        //  add new message to messages
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
        
        if let _ = messagesRef?.addDocument(data: data) {
            
            guard let currentID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            userConversationRef = database.collection("users").document("\(currentID)").collection("conversations")
            recipientConversationRef = database.collection("users").document("\(otherUserID!)").collection("conversations")
      
            let data = ["latestMessage": newMessage, "latestDate": dateString, "isRead": false] as [String : Any]
            userConversationRef?.document("\(conversation!)").updateData(data)
            recipientConversationRef?.document("\(conversation!)").updateData(data)
            
            completion(true)
        } else {
            completion(false)
        }
        
        // update sender latest message
        
        // update recipient latest message
    }
    
    
}
