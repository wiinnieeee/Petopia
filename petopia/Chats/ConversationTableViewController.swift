//
//  ConversationTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 5/6/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseAuth

class ConversationTableViewController: UITableViewController, DatabaseListener {
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
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        // do nothing
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
        // do nothing
    }
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        conversationsList = conversations
        tableView.reloadData()
    }
    
    var conversationsList = [Conversation]()
    var listenerType = ListenerType.conversations
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "convoCell")
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversationsList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConversationTableViewCell
        let conversation = conversationsList[indexPath.row]
        cell.userNameLabel.text = "\((conversation.name)!) - \((conversation.pet)!)"
        cell.userMessageLabel.text = conversation.latestMessage
        cell.accessoryType = .disclosureIndicator

        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // do nothing
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedConvo = conversationsList[indexPath.row]
        
        let vc = ChatViewController()
        vc.title = selectedConvo.name
        vc.conversation = selectedConvo
        vc.isNewConversation = false
        vc.otherUserID = selectedConvo.otherUserID
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
