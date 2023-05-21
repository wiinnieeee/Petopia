//
//  HelpTableViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

let SECTION_NAME = 0
let SECTION_LISTINGS = 1
let SECTION_LANGUAGE = 2
let SECTION_PETSHOPS = 3
let SECTION_VETS = 4
let SECTION_ABOUT = 5
let SECTION_TNC = 6


class HelpTableViewController: UITableViewController {
    
    var user: User = User()
    var currentUser = Auth.auth().currentUser
    var collectionRef: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_NAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            content.text = currentUser?.email
            cell.contentConfiguration = content
            return cell
        }
        else if indexPath.section == SECTION_LISTINGS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "My Listings"
            cell.contentConfiguration = content
            return cell
        } else if indexPath.section == SECTION_PETSHOPS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petShopCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Nearby Pet Shops"
            cell.contentConfiguration = content
            return cell
        } else if indexPath.section == SECTION_LANGUAGE {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petShopCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Languages"
            cell.contentConfiguration = content
            return cell
        } else if indexPath.section == SECTION_VETS {
            let cell = tableView.dequeueReusableCell(withIdentifier: "vetCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Nearby Vets"
            cell.contentConfiguration = content
            return cell
        } else if indexPath.section == SECTION_ABOUT {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "About App"
            cell.contentConfiguration = content
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tncCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Terms and Conditions"
            cell.contentConfiguration = content
            return cell
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
