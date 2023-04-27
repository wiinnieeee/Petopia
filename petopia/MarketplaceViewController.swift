//
//  MarketplaceViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 26/4/2023.
//

import UIKit
import FirebaseAuth

class MarketplaceViewController: UIViewController{
    
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func logoutButton(_ sender: Any) {
        databaseController?.signOutAccount()
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //how to disable the back button owo
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        authController = Auth.auth()
        searchBar.searchTextField.backgroundColor = .white
        
        
        
        
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
