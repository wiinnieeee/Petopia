//
//  ViewWishlistViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 1/6/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MessageUI

class ViewWishlistViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    var animal: WishlistAnimal?
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var isFirebase: Bool? = false
    
    @IBOutlet weak var petImage: UIImageView!
    
    @IBOutlet weak var ageField: UILabel!
    @IBOutlet weak var genderField: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descField: UILabel!
    
    
    @IBAction func contactAction(_ sender: Any) {
        let usersRef = db.collection("users")
        
        usersRef.getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if self.animal?.emailAddress == document.data()["email"] as? String {
                        self.isFirebase = true
                        break
                    }
                }
            }
        }
        
        if isFirebase! {
            // connect to chat controller
        } else {
            let message = " Email: \((animal?.emailAddress ?? "")!)\n Phone number: \((animal?.phoneNumber ?? "" )!)"
            let alert = UIAlertController(title: "Contact Owner", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Email owner", style: .default, handler: {action in
                self.presentMessageComposer()
            }))
            alert.addAction(UIAlertAction(title: "Text owner", style: .default, handler: {action in
                self.presentMessageComposer()
            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            
            
            present(alert, animated: true)
            
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        navigationItem.title = animal?.name
        ageField.text! = animal!.age
        genderField.text! = animal!.gender
        breedLabel.text! = animal!.breed
        descField.text! = animal!.description
        
        if animal?.imageID == "" {
            let imageURL = animal?.imageURL
            let requestURL = URL(string: imageURL!)
            if let requestURL {
                Task {
                    print("Downloading image: " + imageURL!)
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            throw NetworkError.invalidResponse
                        }
                        if let image = UIImage(data: data) {
                            petImage.image = image
                        }
                        else {
                            print("Image invalid: " + imageURL!)
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            else {
                print("Error: URL not valid: " + imageURL!)
            }
        } else {
            let storage = Storage.storage().reference(forURL: "gs://petopiaassg.appspot.com/\(animal!.ownerID!)/\(animal!.imageID!)")

            storage.getData(maxSize: 15 * 1024 * 1024) { data, error in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                } else{
                    let image = UIImage(data: data!)
                    self.petImage.image = image
                    
                    storage.downloadURL { url, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "error")
                        } else {
                            print(url ?? "url")
                            
                        }
                    }
                }
            }
        }
    }
        
    func presentMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
            
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["\((animal?.emailAddress)!)"])
            
        present(composer, animated: true)
    }
            
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print ("Cancelled")
        case .saved:
            print ("Saved")
        case .sent:
            print ("Email sent")
        case .failed:
            print ("Failed to send")
        @unknown default:
            print("Error")
        }
        
        controller.dismiss(animated: true)
    }
            
            
    func presentMessageComposer() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
            
        let composer = MFMessageComposeViewController()
        composer.recipients = [(animal?.phoneNumber)!]
        composer.messageComposeDelegate = self
            
        present(composer, animated: true)
    }
        
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print ("Cancelled case")
        case .sent:
            print ("Sent case")
        case .failed:
            print ("Failed case")
        @unknown default:
            print("Error")
        }
        controller.dismiss(animated: true)
    }
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

