//
//  CommunityTableViewController.swift
//  petopia
//  View Controller that shows the posts created by the all users using the application
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit

class CommunityTableViewController: UITableViewController, DatabaseListener {
    // MARK: Listener Declaration
    var listenerType = ListenerType.posts
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onPostCommentsChange(change: DatabaseChange, postComments: [Comments]) {
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
    
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllPostsChange(change: DatabaseChange, posts: [Posts]) {
        postList = posts
        tableView.reloadData()
    }
    
    func onAllCommentsChange(change: DatabaseChange, comments: [Comments]) {
        // do nothing
    }
    
    var postList: [Posts] = []
    var selectedPost: Posts?
    
    weak var databaseController: DatabaseProtocol?
    
    /// Make comments for the post once the comment button is tapped
    @IBAction func commentButtonTapped (_ sender: UIButton){
        selectedPost = postList[sender.tag]
        performSegue(withIdentifier: "commentSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Register the custom table view cell
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")

        // Sort the posts according to latest date at the top
        postList.sort(by: {$0.date! > $1.date!})
        tableView.reloadData()
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
        return postList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        postList.sort(by: {$0.date! > $1.date!})
        let post = postList[indexPath.row]
        cell.userField.text = post.name!
        cell.titleField.text = post.title!
        cell.descriptionLabel.text = post.content!
        cell.postingDate.text = post.date?.dayAndTimeText
        cell.commentButton.tag = indexPath.row
        
        // Link the action to the comment button
        cell.commentButton.addTarget(self, action: #selector(CommunityTableViewController.commentButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        cell.parentVC = self
        
        return cell
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the post selected to the next view controller
        if(segue.identifier == "commentSegue") {
            if let destination = segue.destination as? CommentsTableViewController {
                if let button: UIButton = sender as! UIButton? {
                    destination.post = postList[button.tag]
                }
            }
        }
    }
    
    
}
