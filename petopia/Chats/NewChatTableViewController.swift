//
//  NewChatTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 7/5/2023.
//

import UIKit
import FirebaseFirestore

class NewChatTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    public var completion: ((Profile) -> (Void))?
    
    var allProfile: [Profile] = []
    var filteredProfile: [Profile] = []
    var prof : Profile = Profile()
    var listenerType = ListenerType.profile
    @IBOutlet weak var noTextLabel: UILabel!
    weak var databaseController: DatabaseProtocol?

    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredProfile = allProfile.filter({(profile: Profile) -> Bool in return (profile.name?.lowercased().contains(searchText) ?? false)})
        } else {
            filteredProfile = allProfile
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
        
        filteredProfile = allProfile
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for users"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.becomeFirstResponder()
        navigationItem.searchController = searchController
        
        // Do any additional setup after loading the view.
        definesPresentationContext = true
        
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("profile")
        
        collectionRef.getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    self.prof = Profile()
                    self.prof.name = document.data() ["name"] as? String
                    self.prof.id = document.documentID
                    
                    self.allProfile.append(self.prof)
                }
            }
        }
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
        return filteredProfile.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nameCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
                    
        var content = nameCell.defaultContentConfiguration()
        let profile = filteredProfile[indexPath.row]
        content.text = profile.name
        nameCell.contentConfiguration = content
        return nameCell

    }
    
    func onAllProfileChange(change: DatabaseChange, profile: [Profile]) {
        allProfile = profile
        updateSearchResults(for: navigationItem.searchController!)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = filteredProfile[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
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
