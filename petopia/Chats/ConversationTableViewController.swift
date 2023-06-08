//
//  ConversationTableViewController.swift
//  petopia
//  Reference: https://youtube.com/playlist?list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf
//  Display all the current conversations of the current user with different users with different pets
//
//  Created by Winnie Ooi on 5/6/2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseAuth

class ConversationTableViewController: UITableViewController, DatabaseListener {
    
    // MARK: Listener Declaration
    var listenerType = ListenerType.conversations
    
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
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Register the custom conversation cell
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConversationTableViewCell
        let conversation = conversationsList[indexPath.row]
        cell.userNameLabel.text = "\((conversation.name)!) - \((conversation.pet)!)"
        cell.userMessageLabel.text = conversation.latestMessage
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Pass the conversation details and the other user ID to the Chat View Controller when the conversaton is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}
