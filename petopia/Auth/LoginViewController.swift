//
//  LoginViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 16/4/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAdd: UITextField!
    

    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
    
    @IBAction func registerAction(_ sender: Any) {
        // do nothing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
        // Do any additional setup after loading the view.
    }
    
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
        authStateListener = authController?.addStateDidChangeListener{
            auth, user in
            if user != nil {
                // User logged in, navigate to main page
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.databaseController?.setupProfileListener()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
//
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
    
    func validAccount () -> Bool {
        var errorMessage: String = ""
//        if !isValidEmail(emailAdd) {
//            errorMessage += "\nInvalid email"
//        }
//
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
