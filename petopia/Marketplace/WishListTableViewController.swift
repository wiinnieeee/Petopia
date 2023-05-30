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
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [Int]) {
        savedID = wishlist
        tableView.reloadData()
    }
    
    //@IBOutlet weak var petImage: UIImageView!
    
    var listenerType = ListenerType.wishlist
    var imageCircle = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    
    var savedID: [Int] = []
    var savedList: [Animal] = []
    var database: Firestore?
    var authController: Auth?
    var usersRef: DocumentReference?
    weak var databaseController: DatabaseProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        database = Firestore.firestore()
        authController = Auth.auth()
        
        Task {
            do {
                let token = try await APIService.shared.getAccessToken()
                let accToken = token.accessToken
                
                for intID in savedID {
                    let savedPet = try await APIService.shared.searchbyID(token: accToken, animalID: intID)
                    self.savedList.append(savedPet)
                }
            }
        }
//
//        petImage.contentMode = UIView.ContentMode.scaleAspectFill
//        petImage.layer.cornerRadius = imageCircle.frame.size.height / 2
//        petImage.layer.masksToBounds = false
//        petImage.clipsToBounds = true
        
  
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return savedList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistCell", for: indexPath)
        let pet = savedList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = pet.name
        //content.secondaryText = "\(String(describing: (pet.type)!)) - \(String(describing: (pet.breeds?.primary)!))"
        cell.contentConfiguration = content
        return cell
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
