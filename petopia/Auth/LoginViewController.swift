//
//  LoginViewController.swift
//  petopia
//  View controller for user to login
//  Reference for unwind Segue: https://medium.com/@ldeme/unwind-segues-in-swift-5-e392134c65fd
//
//
//  Created by Winnie Ooi on 16/4/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var authController: Auth?
    
    // Listen to the authentication stage
    var authStateListener: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAdd: UITextField!
    
    /// Segue for user to unwind to this view after registration or logout successfully
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
    }
    
    /// Action for user to perform login if account is valid
    @IBAction func loginAction(_ sender: Any) {
        if self.validAccount() {
            Task {
                if let loginSuccess = await databaseController?.loginAccount(email: emailAdd.text!, password: password.text!) {
                    if !loginSuccess {
                        self.displayMessage(title: "Error", message: "Provide a valid username and password")
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if the user is already logged, if yes, then directly jump to main page
        authStateListener = authController?.addStateDidChangeListener{
            auth, user in
            if user != nil {
                // User logged in, navigate to main page
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    /// Check if the account is a valid account
    func validAccount () -> Bool {
        var errorMessage: String = ""

        if password.text == "" || password.text!.count<6 {
            errorMessage += "\nPassword must have at least 6 letters"
        }
        
        if errorMessage != "" {
            displayMessage(title: "Invalid account", message: errorMessage)
            return false
        } else {
            return true
        }
    }
    
    /// Initialiser for alert controller to display a message
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }

}
