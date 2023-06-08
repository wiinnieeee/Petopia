//
//  WishListTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class WishListTableViewController: UITableViewController, DatabaseListener {
    // MARK: Listener Declaration
    var listenerType = ListenerType.wishlist
    
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
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    // Listen to the wishlist of the user
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        savedList = wishlist
        tableView.reloadData()
    }
    
    var savedList = [WishlistAnimal]()
    weak var databaseController: DatabaseProtocol?
    
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
        return savedList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistCell", for: indexPath)
        let pet = savedList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = pet.name
        content.secondaryText = "\(pet.type) - \(pet.breed)"
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.removeAnimalfromWishlist(animal: savedList[indexPath.row])
        }
    }
  
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the details of animal to the next VC
        if segue.identifier == "wishlistSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as? ViewWishlistViewController
                let petSelected = savedList[indexPath.row]
                destination?.animal = petSelected
            }
        }
    }
}
