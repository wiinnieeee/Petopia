//
//  RegisterViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 16/4/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?

    // Labels for text field to fill in
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var streetAddField: UITextField!
    @IBOutlet weak var postcodeField: UITextField!
    @IBOutlet weak var suburbField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
    }
    
    /// Create an account using the text inputted
    @IBAction func createAccountButton(_ sender: Any) {
        if self.validAccount()
        { Task {
            if let signUpSuccess = await databaseController?.registerAccount(email: emailField.text!, password: passwordField.text!, name: nameField.text!, phoneNumber: phoneField.text!, streetAdd: streetAddField.text!, postCode: postcodeField.text!, suburb: suburbField.text!, country: countryField.text!){
                if !signUpSuccess {
                    self.displayMessage(title: "Error", message: "Provide a valid username and password")
                }
            }
        }
        }
    }
    
    /// Check if the account is a valid account
    func validAccount () -> Bool {
        var errorMessage: String = ""
        if passwordField.text == "" || passwordField.text!.count<6 {
            errorMessage += "\nPassword must have at least 6 letters"
        }
        
        if errorMessage != "" {
            displayMessage(title: "Invalid account", message: errorMessage)
            return false
        } else {
            return true
        }
    }
    
    /// Initialiser to display the message
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
}
