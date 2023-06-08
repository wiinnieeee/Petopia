//
//  MyProfileTableViewController.swift
//  petopia
//
//  Profile details of the user logged in
//  Created by Winnie Ooi on 31/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyProfileTableViewController: UITableViewController, DatabaseListener {
    
    // Different sections of the table view controller
    let SECTION_USERNAME = 0
    let SECTION_EMAIL = 1
    let SECTION_PHONENUMBER = 2
    let SECTION_ADDRESS = 3
    let SECTION_LOGOUT = 4
    
    // MARK: Listener Declaration
    // Declare the listener type to listen to the current user
    var listenerType: ListenerType = ListenerType.users
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    // Update and obtain data of the current user
    func onUserChange(change: DatabaseChange, user: User) {
        currentUser = user
        tableView.reloadData()
    }
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var currentUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // Populate the sections in the table view using the attributes of the user fetched
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_USERNAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
            cell.textLabel?.text = "Username"
            cell.detailTextLabel?.text = currentUser.name
            return cell
        } else if indexPath.section == SECTION_EMAIL {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            cell.textLabel?.text = "Email Address"
            cell.detailTextLabel?.text = currentUser.email
            return cell
        } else if indexPath.section == SECTION_PHONENUMBER {
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
            cell.textLabel?.text = "Phone Number"
            cell.detailTextLabel?.text = currentUser.phoneNumber
            return cell
        } else if indexPath.section == SECTION_ADDRESS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            cell.textLabel?.text = "Address"
            cell.detailTextLabel?.text = currentUser.address
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logOutCell", for: indexPath)
            cell.textLabel?.text = "Log Out"
            return cell
        }
    }
    
    // Sign out of the user when Log Out row is selected
    // Will return to the Login View Controller page
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section ==  SECTION_LOGOUT {
            databaseController?.signOutAccount()
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
    }
}
