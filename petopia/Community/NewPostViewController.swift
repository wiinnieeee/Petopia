//
//  NewPostViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 4/6/2023.
//

import UIKit

class NewPostViewController: UIViewController, DatabaseListener {
    var listenerType = ListenerType.users
    var currentUser: User = User()
    
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
    

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var contentField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    
    
    @IBAction func submitButton(_ sender: Any) {
        guard let title = titleField.text, let content = contentField.text else {
            return
        }
        
        var newPost = Posts()
        newPost.date = Date()
        newPost.title = title
        newPost.name = currentUser.name!
        newPost.content = content
        
        databaseController?.addPost(newPost: newPost)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
