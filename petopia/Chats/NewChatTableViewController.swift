//
//  NewChatTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NewChatTableViewController: UITableViewController, UISearchResultsUpdating{
    
    var currentUser = Auth.auth().currentUser
    var channels = [Channel]()
    var users: [User] = []
    var filteredUsers: [User] = []
    var user : User = User()
    @IBOutlet weak var noTextLabel: UILabel!
    weak var databaseController: DatabaseProtocol?
    
    var channelsRef: CollectionReference?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredUsers = users.filter({(user: User) -> Bool in return (user.name?.lowercased().contains(searchText) ?? false)})
        } else {
            filteredUsers = users
        }
        tableView.reloadData()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController
        
        filteredUsers = users
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for users"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.becomeFirstResponder()
        navigationItem.searchController = searchController
        
        // Do any additional setup after loading the view.
        definesPresentationContext = true
        
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        
        collectionRef.getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if document.documentID != self.currentUser?.uid{
                        self.user = User()
                        self.user.name = document.data() ["name"] as? String
                        self.user.email = document.data() ["emailAdd"] as? String
                        self.user.id = document.documentID
                        
                        self.users.append(self.user)
                    }
                }
            }
        }
        
        channelsRef = db.collection("users").document("\(String(describing: currentUser?.uid))").collection("channels")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nameCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
                    
        var content = nameCell.defaultContentConfiguration()
        let user = filteredUsers[indexPath.row]
        content.text = user.name
        nameCell.contentConfiguration = content
        return nameCell

    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = filteredUsers[indexPath.row]
        createNewConversation(result: targetUserData)
    }
    
    func createNewConversation (result: User){
        guard let email = result.email, let name = result.name else {
            return
        }
        
        self.navigationController?.popViewController(animated: true)
        
        let vc = ConversationViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
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
