//
//  MyProfileTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 31/5/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class MyProfileTableViewController: UITableViewController, DatabaseListener {
    func onUserListingChange(change: DatabaseChange, userListing: [ListingAnimal]) {
        // do nothing
    }
    
    func onAllListingChange(change: DatabaseChange, listing: [ListingAnimal]) {
        // do nothing
    }
    
    
    let SECTION_USERNAME = 0
    let SECTION_EMAIL = 1
    let SECTION_PHONENUMBER = 2
    let SECTION_ADDRESS = 3
    let SECTION_LOGOUT = 4

    var listenerType: ListenerType = ListenerType.users
    
    func onAllRemindersChange(change: DatabaseChange, reminders: [Reminder]) {
        // do nothing
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [WishlistAnimal]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange, user: User) {
        currentUser = user
        tableView.reloadData()
    }
    
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var currentUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        databaseController = appDelegate?.databaseController

        
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
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_USERNAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath)
            cell.textLabel?.text = "Username"
            cell.detailTextLabel?.text = currentUser.name
            return cell
        } else if indexPath.section == SECTION_EMAIL {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            cell.textLabel?.text = "Email Address"
            cell.detailTextLabel?.text = currentUser.email
            return cell
        } else if indexPath.section == SECTION_PHONENUMBER {
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
            cell.textLabel?.text = "Phone Number"
            cell.detailTextLabel?.text = currentUser.phoneNumber
            return cell
        } else if indexPath.section == SECTION_ADDRESS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            cell.textLabel?.text = "Address"
            cell.detailTextLabel?.text = currentUser.address
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logOutCell", for: indexPath)
            cell.textLabel?.text = "Log Out"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section ==  SECTION_LOGOUT {
            databaseController?.signOutAccount()
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
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
