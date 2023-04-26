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
    
    
//    func isValidEmail(_ emailTextField: UITextField) -> Bool {
//        if let email = emailTextField.text {
//            // regular expression for email format
//            let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//
//            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//            return emailPredicate.evaluate(with: email)
//        }
//        return false
//    }
    
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
    
    func validAccount () -> Bool {
        var errorMessage: String = ""
//        if !isValidEmail(emailField) {
//            errorMessage += "\nInvalid email"
//        }
//
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
    
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
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
