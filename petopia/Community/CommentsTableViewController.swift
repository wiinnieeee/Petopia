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
    var listenerType = ListenerType.users
    
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
    var savedComment = [Comments]()
    var post: Posts?
    var commentList = [Comments]()
    weak var databaseController: DatabaseProtocol?
    var database = Firestore.firestore()
    var commentsRef: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "commentsCell")
        
        setupCommentsListener()
        tableView.reloadData()
    }
    
    @IBAction func addComment(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Comment",
                                                message: nil, preferredStyle: .alert)
        
        alertController.addTextField(){ (textField) in
            textField.placeholder = "Enter Comment"
        }
        
        let submitAction = UIAlertAction(title: "Submit",
                                         style: .default) { [weak alertController] _ in
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedComment.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        let comment = savedComment[indexPath.row]
        cell.userLabel.text = comment.name
        cell.dateLabel.text = comment.date?.dayAndTimeText
        cell.commentLabel.text = comment.text!
        return cell
    }
    
    func setupCommentsListener() {
        commentsRef = database.collection("posts").document((post?.id!)!).collection("comments")
        commentsRef!.addSnapshotListener() {
            (querySnapshot, error) in
            
            // inside closure, ensure snapshot valid but not just a nil value
            // if nil, need to return immediately
            
            guard let querySnapshot = querySnapshot else {
                print ("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            // if valid, we call the parseRemindersSnapshot to handle parsing changes made on Firestore
            self.parseCommentsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseCommentsSnapshot (snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            
            // paying attention to changes only
            // easily handle different behaviour based on type of change such as adding, modifying, deleting
            // when first time the snapshot called during each app launc, treat all existing records as being added
            var parsedComments: Comments?
            
            do {
                // done using Codable - do catch statement
                parsedComments = try change.document.data(as: Comments.self)
            } catch {
                print ("Unable to decode listing.")
                return
            }
            
            // make sure parsedHero isn't nil
            guard let comment = parsedComments else {
                print ("Document doesn't exist")
                return
            }
            
            // if change type is added, insert array at appropiate place
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
