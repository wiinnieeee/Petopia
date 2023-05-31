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
    var wishlistList: [Int]
    
    var currentUser: User?
    
    var registerSuccessful: Bool = false
    
    override init(){
        FirebaseApp.configure()
        
        // assign Firebase var
        authController = Auth.auth()
        database = Firestore.firestore()
        reminderList = [Reminder]()
        wishlistList = [Int]()
        
        usersRef = database.collection("users")
        
        super.init()
        
        if authController.currentUser != nil{
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            self.setupRemindersListener()
            self.setupUserListener()
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
            remindersRef = database.collection("users").document("\((authController.currentUser?.uid)!)").collection("reminders")
            self.setupRemindersListener()
            self.setupUserListener()
            
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
            self.setupRemindersListener()
            self.setupUserListener()
            
        }
        catch {
            print ("Authenciation failed with error: \(String(describing: error))")
            return false
        }
        return isSuccessful
    }
    
    func signOutAccount() {
        do {
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
    
    func addAnimaltoWishlist(newAnimal: Animal?) {
        let documentID = authController.currentUser!.uid
        database.collection("users").document("\(documentID)").updateData(["wishlist": FieldValue.arrayUnion([newAnimal?.id as Any])])
    }
    
    func removeAnimalfromWishlist (animal: Animal?) {
        let documentID = authController.currentUser!.uid
        database.collection("users").document("\(documentID)").updateData(["wishlist": FieldValue.arrayRemove([animal?.id as Any])])
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
    
    func parseRemindersSnapshot (snapshot: QuerySnapshot){
        // create for-each loop togo through each document change in snapshot
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedReminder: Reminder?
            
            do {
                
                // decode document data as Superhero object
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
        
        if let intArr = snapshot.data()["wishlist"] as? [Int] {
            for intID in intArr {
                wishlistList.append(intID)
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.wishlist || listener.listenerType == ListenerType.all {
                listener.onAllWishlistChange (change: .update, wishlist: wishlistList)
            }
            if listener.listenerType == ListenerType.users || listener.listenerType == ListenerType.all {
                listener.onUserChange (change: .update, user: currentUser!)
            }
        }
    }
}
