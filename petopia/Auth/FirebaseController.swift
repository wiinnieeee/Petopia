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
    var defaultProfile: Profile
    
    var authController: Auth
    var database: Firestore
    
    var usersRef: CollectionReference?
    var profileRef: CollectionReference?
    
    var registerSuccessful: Bool = false
    
    override init(){
        FirebaseApp.configure()
        
        // assign Firebase var
        authController = Auth.auth()
        database = Firestore.firestore()
        defaultProfile = Profile()
        
        // assign all references
        usersRef = database.collection("users")
        profileRef = database.collection("profile")
        
        super.init()
    }
    
    func cleanup() {
        // do nothing
    }
    
    func addListener(listener: DatabaseListener) {
        // onPetsChange smtg
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func registerAccount(email: String, password: String, name: String, phoneNumber: String, streetAdd: String, postCode: String, suburb: String, country: String) async -> Bool {
        
        var isSuccessful = false
        
        do
        { let authResult = try await authController.createUser(withEmail: email, password: password)
            
            self.addUser(emailAdd: email, name: name, phoneNumber: phoneNumber, streetAdd: streetAdd, postCode: postCode, suburb: suburb, country: country)
            
            isSuccessful = true
        } catch {
            print ("User creation failed with error: \(String(describing: error))")
            return false
        }
        return isSuccessful
    }
    
    func loginAccount(email: String, password: String) async ->  Bool {
        var isSuccessful = false
        
        do
        {   let authResult = try await authController.signIn(withEmail: email, password: password)
            isSuccessful = true
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
        let newProfile: Profile = self.addProfile(profileName: authController.currentUser!.email!)
        
        if let profileRef = profileRef?.document(newProfile.id!){
            usersRef?.document(authController.currentUser!.uid).setData(["profile": profileRef])
        }
        
        let userProfileRef = profileRef?.document(newProfile.id!)
        let documentID = authController.currentUser!.uid
        let data = ["profile": userProfileRef as Any, "emailAdd": emailAdd, "phoneNumber": phoneNumber, "streetAdd": streetAdd, "postcode": postCode, "suburb": suburb, "country": country] as [String : Any]
        database.collection("users").document(documentID).setData(data as [String: Any])
        
    
    }
    
    func addProfile(profileName: String) -> Profile{
        let profile = Profile()
        profile.name = profileName
        if let profileRef = profileRef?.addDocument(data: ["name": profileName]){
            profile.id = profileRef.documentID
        }
        return profile
    }
    
    func deleteProfile (profile: Profile){
        if let profileID = profile.id {
            profileRef?.document(profileID).delete()
        }
    }
    
    func setupProfileListener() {
        let userRef = database.collection("users").document(authController.currentUser!.uid)
        userRef.getDocument {
            (document, error) in
            
            if let document = document, document.exists {
                let profileRef = document.get("profile") as! DocumentReference
                
                profileRef.addSnapshotListener(){
                    (documentsnapshot, error) in
                    guard let documentsnapshot = documentsnapshot else {
                        print ("Error fetching document: \(String(describing: error))")
                        return
                    }
                    
                    self.parseProfileSnapshot (snapshot: documentsnapshot)
                }
            } else {
                print ("User document doesn't exist.")
            }
        }
    }
    
    func parseProfileSnapshot (snapshot: DocumentSnapshot){
        defaultProfile = Profile()
        defaultProfile.name = snapshot.data()! ["name"] as? String
        defaultProfile.id = snapshot.documentID
    }
}
