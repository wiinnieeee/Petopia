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
import FirebaseStorage

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
    
    var animal: ListingAnimal?
    
    @IBAction func addWishlist(_ sender: Any) {
        let newRow = WishlistAnimal(breed: (animal?.breed)!, age: (animal?.age)!, gender: (animal?.gender)!, name: (animal?.name)!, type: (animal?.type)!, description: animal?.desc ?? "", emailAddress: (animal?.emailAddress)!, phoneNumber: (animal?.phoneNumber)!, imageID: animal?.imageID, imageURL: animal?.imagePath, ownerID: animal?.ownerID)
        databaseController?.addAnimaltoWishlist(newAnimal: newRow) {isDuplicate in
            if isDuplicate {
                let alertController = UIAlertController(title: "Duplicate Entry", message: "This animal is already in the wishlist.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func contactButton(_ sender: Any) {
        let usersRef = db.collection("users")
        
        usersRef.getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if self.animal?.emailAddress == document.data()["email"] as? String {
                        self.isFireBase = true
                        break
                    }
                }
            }
        }
        
        if isFireBase {
            // connect to chat controller
        } else {
            let message = " Email: \((animal?.emailAddress ?? "")!)\n Phone number: \((animal?.phoneNumber ?? "" )!)"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petImageView.layer.cornerRadius = 1
        petImageView.clipsToBounds = true
        
        if animal?.imageID == nil {
            let imageURL = animal?.imagePath!
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
                            petImageView.image = image
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
            let filename = ("\(animal!.imageID!).jpg")
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            let downloadTask = storage.write(toFile:fileURL)
            downloadTask.observe(.success) { snapshot in
                let image = self.loadImageData(filename: filename)
                self.petImageView.image = image
            }
            
            
            downloadTask.observe(.failure){
                snapshot in print("\(String(describing: snapshot.error))")
            }
        }
        
        ageLabel.text = animal?.age!
        breedLabel.text = animal?.breed!
        genderLabel.text = animal?.gender!
        descriptionLabel.text = animal?.desc
        
        descriptionLabel.numberOfLines = 0
        
        navigationItem.title = animal?.name!
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    func showMailComposer() {
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
    
    
    func showMessageComposer() {
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
