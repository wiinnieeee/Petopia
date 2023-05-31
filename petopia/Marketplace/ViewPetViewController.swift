//
//  ViewPetViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 21/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageUI

class ViewPetViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    
    
    @IBOutlet weak var typeBreedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    weak var databaseController: DatabaseProtocol?
    var db = Firestore.firestore()
    var isFireBase: Bool = false
    
    @IBAction func addWishlist(_ sender: Any) {
        databaseController?.addAnimaltoWishlist(newAnimal: animal)
    }
    
    @IBAction func contactButton(_ sender: Any) {
        let usersRef = db.collection("users")
        
        usersRef.getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if self.animal?.contact?.email == document.data()["email"] as? String {
                        self.isFireBase = true
                        break
                    }
                }
            }
        }
        
        if isFireBase {
            // connect to chat controller
        } else {
            let message = " Email: \((animal?.contact?.email ?? "")!)\n Phone number: \((animal?.contact?.phone ?? "" )!)"
            let alert = UIAlertController(title: "Contact Owner", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Email owner", style: .default, handler: {action in
                self.showMailComposer()
            }))
            alert.addAction(UIAlertAction(title: "Text owner", style: .default, handler: {action in
                self.showMessageComposer()
            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            
            
            present(alert, animated: true)
            
        }
    }
    
    var animal: Animal?
    var imageURL: String = ""
    var nameText: String = ""
    var breedText: String = ""
    var ageText: String = ""
    var genderText: String = ""
    var vaccText: String = ""
    var descText: String = ""
    var emailText: String = ""
    var phoneText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petImageView.layer.cornerRadius = 1
        petImageView.clipsToBounds = true
        
        let requestURL = URL(string: imageURL)
        if let requestURL {
            Task {
                print("Downloading image: " + imageURL)
                do {
                    let (data, response) = try await URLSession.shared.data(from: requestURL)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw NetworkError.invalidResponse
                    }
                    if let image = UIImage(data: data) {
                        petImageView.image = image
                    }
                    else {
                        print("Image invalid: " + imageURL)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        else {
            print("Error: URL not valid: " + imageURL)
        }
        
        // Do any additional setup after loading the view.
        ageLabel.text =  ageText
        genderLabel.text = genderText
        breedLabel.text = breedText
        descriptionLabel.text = descText
        descriptionLabel.numberOfLines = 0
        
        navigationItem.title = nameText
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["\((animal?.contact?.email)!)"])
        
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
    
    
    func showMessageComposer() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        let composer = MFMessageComposeViewController()
        composer.recipients = [(animal?.contact?.phone)!]
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
        controller.dismiss(animated: true
        )
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
