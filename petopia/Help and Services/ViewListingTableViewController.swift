//
//  ViewListingTableViewController.swift
//  petopia
//  View the user's listings
//
//  Created by Winnie Ooi on 3/6/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewListingTableViewController: UITableViewController, DatabaseListener {
    
    //MARK: Listener Declaration
    var listenerType = ListenerType.userlistings
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    // Listen to the user's own listings
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        listingList = userListing
        tableView.reloadData()
    }

    var listingList: [ListingAnimal] = []
    var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath)
        let listing = listingList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = listing.name
        content.secondaryText = listing.breed
        cell.contentConfiguration = content
        return cell
    }

    // MARK: Navigation
    // Prepare to pass the data of the listing to the next view controller to view the listing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listingSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? DetailListingViewController
                let petSelected = listingList[indexPath.row]
                destination?.animal = petSelected
            }
        }
    }
}
