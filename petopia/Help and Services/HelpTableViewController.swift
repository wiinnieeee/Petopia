//
//  HelpTableViewController.swift
//  petopia
//  Contains all the settings and services of application
//
//
//
//  Created by Winnie Ooi on 27/4/2023.
//

import UIKit

// Different sections in the Table View Controller
let SECTION_NAME = 0
let SECTION_LISTINGS = 1
let SECTION_PETSHOPS = 2
let SECTION_VETS = 3
let SECTION_ABOUT = 4
let SECTION_TNC = 5
let SECTION_LIGHTDARK = 6

class HelpTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register a custom cell to select the viewing mode
        tableView.register(UINib(nibName: "ViewModeTableViewCell", bundle: nil), forCellReuseIdentifier: "viewModeCell")
        tableView.reloadData()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Initialise the name of different sections
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_NAME {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "My Profile"
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
        } else if indexPath.section == SECTION_TNC{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tncCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "Terms and Conditions"
            cell.contentConfiguration = content
            return cell
        } else {
            // Set the cell as custom table view cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "viewModeCell", for: indexPath) as! ViewModeTableViewCell
            cell.viewLabel.text = "Viewing Mode"
            return cell
        }
    }
}
