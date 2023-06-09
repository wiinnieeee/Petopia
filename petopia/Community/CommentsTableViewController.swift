//
//  CommentsTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CommentsTableViewController: UITableViewController, DatabaseListener {
    // MARK: Listener Declaration
    var listenerType = ListenerType.users
    
    func onAllConversationsChange(change: DatabaseChange, conversations: [Conversation]) {
        // do nothing
    }
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        currentUser = user
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
    
    var currentUser: User?
    var post: Posts?
    var savedComment = [Comments]()
    var commentList = [Comments]()
    
    weak var databaseController: DatabaseProtocol?
    var database = Firestore.firestore()
    var commentsRef: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Register the custom table view cell
        tableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "commentsCell")
        
        // Listen to the comments for each post
        setupCommentsListener()
        tableView.reloadData()
    }
    
    @IBAction func addComment(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .alert)
        
        // Provide text field for the user to write down their comments
        alertController.addTextField(){ (textField) in
            textField.placeholder = "Enter Comment"
        }
        
        // Action for user to submit the comment once finish typing
        // Adds the comment to the collection of each post as well
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alertController] _ in
            guard let textFields = alertController?.textFields else { return }
            let comment = textFields[0].text
            let date = Date()
            let name = self.currentUser?.name!
            let newComment = Comments(name: name, date: date, text: comment)
            self.databaseController?.addComments(post: self.post, newComment: newComment)
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
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
        return savedComment.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        // Latest comment shown at the top
        savedComment.sort(by: {$0.date! > $1.date!})
        let comment = savedComment[indexPath.row]
        cell.userLabel.text = comment.name
        cell.dateLabel.text = comment.date?.dayAndTimeText
        cell.commentLabel.text = comment.text!
        return cell
    }
    
    // MARK: Comments Listener
    func setupCommentsListener() {
        // Comments collection reference is found using the post id
        commentsRef = database.collection("posts").document((post?.id!)!).collection("comments")
        commentsRef!.addSnapshotListener() {
            (querySnapshot, error) in
        
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseCommentsSnapshot(snapshot: querySnapshot)
        }
    }
    
    // Parse the snapshots of the comments to update inside the table view
    func parseCommentsSnapshot (snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
    
            var parsedComments: Comments?
            
            do {
                parsedComments = try change.document.data(as: Comments.self)
            } catch {
                print ("Unable to decode comments.")
                return
            }

            guard let comment = parsedComments else {
                print ("Document doesn't exist")
                return
            }

            if change.type == .added {
                savedComment.insert(comment, at: Int(change.newIndex))
            } else if change.type == .modified {
                savedComment [Int (change.oldIndex)] = comment
            } else if change.type == .removed {
                savedComment.remove(at: Int(change.oldIndex))
            }
        }
        tableView.reloadData()
    }
}
